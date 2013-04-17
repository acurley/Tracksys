require 'spec_helper'

describe "AutomationMessages" do
  describe "GET /admin/automation_messages" do
    it "renders" do
      visit admin_automation_messages_path
      page.should have_content "Automation Messages"
    end
  end
  describe "GET /patron/automation_messages" do
    it "renders" do
      visit patron_automation_messages_path
      page.should have_content "Automation Messages"
    end
  end
end
