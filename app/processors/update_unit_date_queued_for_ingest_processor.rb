class UpdateUnitDateQueuedForIngestProcessor < ApplicationProcessor
  # Written by: Andrew Curley (aec6v@virginia.edu) and Greg Murray (gpm2a@virginia.edu)
  # Written: January - March 2010

  subscribes_to :update_unit_date_queued_for_ingest, :ack => 'client', 'activemq.prefetchSize' => 1
  publishes_to :queue_objects_for_fedora

  def on_message(message)
    logger.debug 'UpdateUnitDateQueuedForIngestProcessor received: ' + message

    # decode JSON message into Ruby hash
    hash = ActiveSupport::JSON.decode(message).symbolize_keys

    # Validate incoming message
    fail "Parameter 'unit_id' is required" if hash[:unit_id].blank?
    fail "Parameter 'source' is required" if hash[:source].blank?
    @messagable_id = hash[:unit_id]
    @messagable_type = 'Unit'
    @workflow_type = AutomationMessage::WORKFLOW_TYPES_HASH.fetch(self.class.name.demodulize)

    @unit_id = hash[:unit_id]
    @source = hash[:source]
    @working_unit = Unit.find(@unit_id)
    @messagable = @working_unit

    # Update date_unit_queued_for_ingest value
    @working_unit.update_attribute(:date_queued_for_ingest, Time.now)

    message = ActiveSupport::JSON.encode(unit_id: @unit_id, source: @source)
    publish :queue_objects_for_fedora, message
    on_success "Date queued for ingest for Unit #{@unit_id} has been updated."
  end
end
