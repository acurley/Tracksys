require 'spec_helper'

describe "admin dashboard" do
  describe "visit" do
    it "renders" do
      visit "/admin"
      response.status.should be(200)
    end
  end
end
