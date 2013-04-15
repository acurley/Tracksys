require 'spec_helper'

describe "admin dashboard" do
  describe "visit" do
    it "renders" do
      get admin_root_path
      response.status.should be(200)
    end
  end
end
