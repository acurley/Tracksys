class AddAutomationMessagesCounterCacheToTeis < ActiveRecord::Migration
  def change
    change_table(:teis) do |t|
      t.integer :automation_messages_count, :default => 0
    end
  end
end
