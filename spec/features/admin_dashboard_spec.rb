require 'spec_helper'

describe "admin dashboard" do
  describe "GET /admin" do
    it "renders" do
      visit admin_root_path
      page.should have_content "Tracksys - Admin Portal"
    end
  end
end
