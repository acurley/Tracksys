require 'spec_helper'

describe "Orders" do
  describe "GET /admin/orders" do
    it "renders" do
      visit admin_orders_path
      page.should have_content("Orders")
    end
  end

  describe "GET /patron/orders" do
    it "renders" do
      visit patron_orders_path
      page.should have_content("Orders")
    end
  end
end
