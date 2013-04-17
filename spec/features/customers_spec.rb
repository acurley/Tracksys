require 'spec_helper'

describe "Customers" do
  before do
    @customer = FactoryGirl.create(:customer)
  end

  describe "GET customers#index" do
    it "displays customers (admin)" do
      visit admin_customers_path
      page.should have_content("#{@customer.name}")
    end

    it "displays customers (patron)" do
      visit patron_customers_path
      page.should have_content("#{@customer.name}")
    end
  end

  describe "GET customers#show" do
    it "display customer details (admin)" do
      visit admin_customers_path
      within(:xpath, "//tr[@id=\"customer_#{@customer.id}\"]") do
        click_link "Details"
      end
      page.should have_content("#{@customer.name}")
    end

    it "display customer details (patron)" do
      visit patron_customers_path
      within(:xpath, "//tr[@id=\"customer_#{@customer.id}\"]") do
        click_link "Details"
      end
      page.should have_content("#{@customer.name}")
    end
  end
end