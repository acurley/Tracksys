require 'spec_helper'

describe "Bibls" do
  before do
    @bibl = FactoryGirl.create(:bibl)
  end

  describe "GET bibls#index" do
    it "displays bibls (admin)" do
      visit admin_bibls_path
      page.should have_content("#{@bibl.title}")
    end

    it "displays bibls (patron)" do
      visit patron_bibls_path
      page.should have_content("#{@bibl.title}")
    end
  end

  describe "GET bibls#show" do
    it "display bibl details (admin)" do
      visit admin_bibls_path
      within(:xpath, "//tr[@id=\"bibl_#{@bibl.id}\"]") do
        click_link "Details"
      end
      page.should have_content("#{@bibl.barcode}")
    end

    it "display bibl details (patron)" do
      visit patron_bibls_path
      within(:xpath, "//tr[@id=\"bibl_#{@bibl.id}\"]") do
        click_link "Details"
      end
      page.should have_content("#{@bibl.barcode}")
    end
  end
end