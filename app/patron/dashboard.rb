ActiveAdmin.register_page 'Dashboard', namespace: :patron do
  menu priority: 1

  content do
    div class: 'two-column' do
      panel 'Order Processing', namespace: :patron, priority: 1, width: '50%' do
        table do
          tr do
            td { 'Requests Awaiting Approval' }
            td { link_to "#{Order.awaiting_approval.not_from_fine_arts.count}", patron_orders_path(scope: 'awaiting_approval') }
          end
          tr do
            td { 'Deferred Requests' }
            td { link_to "#{Order.deferred.not_from_fine_arts.count}", patron_orders_path(scope: 'deferred') }
          end
          tr do
            td { 'Units Awaiting Copyright Approval' }
            td { link_to "#{Unit.awaiting_copyright_approval.count}", patron_units_path(scope: 'awaiting_copyright_approval') }
          end
          tr do
            td { 'Units Awaiting Condition Approval' }
            td { link_to "#{Unit.awaiting_condition_approval.count}", patron_units_path(scope: 'awaiting_condition_approval') }
          end
        end
      end
    end

    div class: 'two-column' do
      panel 'Digitization Services Checkouts', namespace: :patron, priority: 2, width: '50%' do
        table do
          tr do
            td { 'Unreturned Material' }
            td { link_to "#{Unit.overdue_materials.count}", patron_units_path(scope: 'overdue_materials') }
          end
          tr do
            td { 'Materials Currently in Digitization Services' }
            td { link_to "#{Unit.checkedout_materials.count}", patron_units_path(scope: 'checkedout_materials') }
          end
        end
      end
    end
  end

  # section "Requests Awaiting Approval (#{Order.awaiting_approval.count})", :namespace => :patron, :priority => 1, :width => '33%', :toggle => 'hide' do
  #   table_for Order.awaiting_approval do
  #     column :id do |order|
  #       link_to order.id, patron_order_path(order)
  #     end
  #     column (:date_due) {|order| format_date(order.date_due)}
  #     column :agency
  #     column "Name" do |order|
  #       link_to order.customer_full_name, patron_customer_path(order.customer)
  #     end
  #   end
  # end

  # section "Deferred Requets (#{Order.deferred.count})", :width => '33%', :namespace => :patron, :toggle => 'hide' do
  #   table_for Order.deferred do
  #     column :id do |order|
  #       link_to order.id, patron_order_path(order)
  #     end
  #     column (:date_due){|order| format_date(order.date_due)}
  #     column (:date_deferred) {|order| format_date(order.date_deferred)}
  #     column :agency
  #     column "Name" do |order|
  #       link_to order.customer_full_name, patron_customer_path(order.customer)
  #     end
  #   end
  # end

  # section "Units Awaiting Condition Approval (#{Unit.awaiting_copyright_approval.count})", :width => '33%', :namespace => :patron, :toggle => 'hide' do
  #   table_for Unit.awaiting_condition_approval do
  #     column ("Unit ID") {|unit| link_to unit.id, patron_unit_path(unit)}
  #     column (:order_date_due) {|unit| format_date(unit.order_date_due)}
  #     column :bibl_title
  #     column :bibl_call_number
  #   end
  # end

  # section "Units Awaiting Copyright Approval (#{Unit.awaiting_copyright_approval.count})", :width => '33%', :namespace => :patron, :toggle => 'hide' do
  #   table_for Unit.awaiting_copyright_approval do
  #     column ("Unit ID") {|unit| link_to unit.id, patron_unit_path(unit)}
  #     column (:order_date_due) {|unit| format_date(unit.order_date_due)}
  #     column :bibl_title
  #     column :bibl_call_number
  #   end
  # end

  # section "Materials Currently in Digitization Services (#{Unit.checkedout_materials.count})", :width => '33%', :namespace => :patron, :toggle => 'hide' do
  #   table_for Unit.checkedout_materials do
  #     column("Unit ID") {|unit| link_to unit.id, patron_unit_path(unit)}
  #     column("Date Checked Out") {|unit| format_date(unit.date_materials_received)}
  #     column :bibl_title
  #     column :bibl_call_number
  #   end
  # end

  # section "Unreturned Material (#{Unit.overdue_materials.count})", :width => '33%', :namespace => :patron, :toggle => 'hide' do
  #   table_for Unit.overdue_materials do
  #     column("Unit ID") {|unit| link_to unit.id, patron_unit_path(unit)}
  #     column("Date Checked Out") {|unit| format_date(unit.date_materials_received)}
  #     column :bibl_title
  #     column :bibl_call_number
  #   end
  # end
end
