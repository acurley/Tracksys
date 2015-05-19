class UpgradeIndexingScenario < ActiveRecord::Migration
  def change
    change_table(:indexing_scenarios, bulk: true) do |t|
      t.integer :bibls_count, default: 0
      t.integer :components_count, default: 0
      t.integer :master_files_count, default: 0
      t.integer :units_count, default: 0
    end
  end
end
