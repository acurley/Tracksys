class UpdateCounters < ActiveRecord::Migration
  def change
    say 'Updating customer.orders_count and customer.master_files_count.'
    Customer.find(:all).each do|c|
      Customer.update_counters c.id, orders_count: c.orders.count
      Customer.update_counters c.id, master_files_count: c.master_files.count
    end

    say 'Updating order.units_count, order.invoices_count, order.master_files_count and order.automation_messages_count'
    Order.find(:all).each do|o|
      Order.update_counters o.id, units_count: o.units.count
      Order.update_counters o.id, automation_messages_count: o.automation_messages.count
      Order.update_counters o.id, invoices_count: o.invoices.count
      Order.update_counters o.id, master_files_count: o.master_files.count
    end

    say 'Updating unit.master_files_count and unit.automation_messages_count'
    Unit.find(:all).each do|u|
      Unit.update_counters u.id, master_files_count: u.master_files.count
      Unit.update_counters u.id, automation_messages_count: u.automation_messages.count
    end

    say 'Updating bibl.units_count, bibl.master_files_count, bibl.orders_count and bibl.automation_messages_count'
    Bibl.find(:all).each do|b|
      Bibl.update_counters b.id, units_count: b.units.count
      Bibl.update_counters b.id, orders_count: b.orders.count
      Bibl.update_counters b.id, automation_messages_count: b.automation_messages.count
      Bibl.update_counters b.id, master_files_count: b.master_files.count
    end

    # Given the large number of MasterFile objects, this migration will proceede in batches
    say 'Updating master_file.automation_messages_count'
    MasterFile.find_in_batches(batch_size: 5000) do |master_files|
      ids = master_files.map(&:id)
      MasterFile.update_all ["automation_messages_count=(select count(*) from automation_messages where automation_messages.messagable_type='MasterFile' and automation_messages.messagable_id=master_files.id)"], "id IN (#{ids.join(', ')})"
    end

    say 'Updating agency.orders_count'
    Agency.find(:all).each do|a|
      Agency.update_counters a.id, orders_count: a.orders.count
    end

    say 'Updateing archive.units_count'
    Archive.find(:all).each do|a|
      Archive.update_counters a.id, units_count: a.units.count
    end

    say 'Updating departments.customers_count'
    Department.find(:all).each do|d|
      Department.update_counters d.id, customers_count: d.customers.count
    end

    say 'Updating heard_about_service.customers_count'
    HeardAboutService.find(:all).each do|h|
      HeardAboutService.update_counters h.id, customers_count: h.customers.count
    end

    say 'Update intended_use.units_count'
    IntendedUse.find(:all).each do|i|
      IntendedUse.update_counters i.id, units_count: i.units.count
    end

    say 'Updating academic_status.customers_count'
    AcademicStatus.find(:all).each do|a|
      AcademicStatus.update_counters a.id, customers_count: a.customers.count
    end

    say 'Updating availability_policy.orders_count, availability_policy.units_count, availability_policy.components_counts and availability_policy.master_files_count'
    AvailabilityPolicy.find(:all).each do|a|
      AvailabilityPolicy.update_counters a.id, bibls_count: a.bibls.count
      AvailabilityPolicy.update_counters a.id, units_count: a.units.count
      AvailabilityPolicy.update_counters a.id, components_count: a.components.count
      AvailabilityPolicy.update_counters a.id, master_files_count: a.master_files.count
    end

    say 'Updating use_right.orders_count, use_right.units_count, use_right.components_counts and use_right.master_files_count'
    UseRight.find(:all).each do|u|
      UseRight.update_counters u.id, bibls_count: u.bibls.count
      UseRight.update_counters u.id, units_count: u.units.count
      UseRight.update_counters u.id, components_count: u.components.count
      UseRight.update_counters u.id, master_files_count: u.master_files.count
    end

    say 'Updating indexing_scenario.orders_count, indexing_scenario.units_count, indexing_scenario.components_counts and indexing_scenario.master_files_count'
    IndexingScenario.find(:all).each do|i|
      IndexingScenario.update_counters i.id, bibls_count: i.bibls.count
      IndexingScenario.update_counters i.id, units_count: i.units.count
      IndexingScenario.update_counters i.id, components_count: i.components.count
      IndexingScenario.update_counters i.id, master_files_count: i.master_files.count
    end

    say 'Updating component.master_files_count'
    Component.find(:all).each do|c|
      Component.update_counters c.id, master_files_count: c.master_files.count
    end
  end
end
