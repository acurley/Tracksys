class QaUnitDataProcessor < ApplicationProcessor
  # Written by: Andrew Curley (aec6v@virginia.edu) and Greg Murray (gpm2a@virginia.edu)
  # Written: January - March 2010

  subscribes_to :qa_unit_data, :ack => 'client', 'activemq.prefetchSize' => 1
  publishes_to :qa_filesystem_and_iview_xml

  def on_message(message)
    logger.debug 'QAUnitDataProcessor received: ' + message

    # decode JSON message into Ruby hash
    hash = ActiveSupport::JSON.decode(message).symbolize_keys

    # Validate incoming message
    fail "Parameter 'unit_id' is required" if hash[:unit_id].blank?

    @unit_id = hash[:unit_id]

    # If this Unit.find fails, a unit with this id does not exist in Tracksys
    @working_unit = Unit.find(@unit_id)
    @messagable_id = hash[:unit_id]
    @messagable_type = 'Unit'
    @workflow_type = AutomationMessage::WORKFLOW_TYPES_HASH.fetch(self.class.name.demodulize)

    @working_order = @working_unit.order

    # Create error message holder array
    failure_messages = []

    #-------------------------
    # QA Logic
    #-------------------------

    # If an order is input through the admin interface, there is no auto-populated value for
    # order.delivery_method

    # Fail if @working_unit.date_patron_deliverables_ready is already filled out
    if @working_unit.date_patron_deliverables_ready
      failure_messages << "Unit #{@unit_id} already has a value for date_patron_deliverables_ready."
    end

    # Fail if @working_unit.date_dl_deliverables_ready is already filled out
    if @working_unit.date_dl_deliverables_ready
      failure_messages << "Unit #{@unit_id} already has a value for date_dl_deliverables_ready."
    end

    # Must have a unit status
    unless @working_unit.unit_status
      failure_messages << "Unit #{@unit_id} must have a valid unit status."
    end

    # Check if unit is assigned to bibl record
    unless @working_unit.bibl
      failure_messages << "Unit #{@unit_id} is not assigned to a bibl record."
    end

    # Fail if @working_unit.intended_use is blank
    unless @working_unit.intended_use
      failure_messages << "Unit #{@unit_id} has no intended use.  All units that participate in this workflow must have an intended use."
    end

    # In response to DSSR staff's inconsistent use of the date_approved field, this logic will now warn but enforce the inclusion of a date_approved value.
    unless @working_order.date_order_approved?
      # Define and undefine @order_id within this conditional to ensure that only this message is attached to the Order.
      @order_id = @working_order.id
      on_failure "Order #{@order_id} is not marked as approved.  Since this unit is undergoing finalization, the workflow has automatically updated this value and changed the order_status to approved."
      @working_order.date_order_approved = Time.now
      @working_order.order_status = 'approved'
      @working_order.save!
      @order_id = nil
    end

    #-------------------------
    # Failure Message Handling
    #-------------------------

    if failure_messages.empty?
      message = ActiveSupport::JSON.encode(unit_id: @unit_id)
      publish :qa_filesystem_and_iview_xml, message
      on_success "Unit #{@unit_id} has passed the QaUnitDataProcessor."
    else
      failure_messages.each do|message|
        on_failure message
        if message == failure_messages.last
          on_error "Unit #{@unit_id} has failed the QA Unit Data Processor"
        end
      end
    end
  end
end
