class AddTeisCountToAvailabilityPolicies < ActiveRecord::Migration
  def change 
    add_column :availability_policies, :teis_count, :integer
  end
end
