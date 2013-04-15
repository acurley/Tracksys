require 'spec_helper'

describe "patron dashboard" do
  describe "visit" do
    it "renders" do
      visit "/patron"
      page.should have_content "Tracksys - Patron Portal"
    end
  end
end
