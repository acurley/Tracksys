require 'spec_helper'

describe "Units" do
  describe "GET /admin/units" do
    it "renders" do
      visit admin_units_path
      page.should have_content("Units")
    end
  end

  describe "GET /patron/units" do
    it "renders" do
      visit patron_units_path
      page.should have_content("Units")
    end
  end
end
