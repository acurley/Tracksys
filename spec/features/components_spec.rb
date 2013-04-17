require 'spec_helper'

describe "Components" do
  describe "GET /admin/components" do
    it "renders" do
      visit admin_components_path
      page.should have_content("Components")
    end
  end

  describe "GET /patron/components" do
    it "renders" do
      visit patron_components_path
      page.should have_content("Components")
    end
  end
end
