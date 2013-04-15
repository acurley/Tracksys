require 'spec_helper'

describe "admin dashboard" do
  describe "visit" do
    it "renders" do
      visit "/admin"
      page.should have_content "Tracksys - Admin Portal"
    end
  end
end
