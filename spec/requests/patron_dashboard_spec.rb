require 'spec_helper'

describe "patron dashboard" do
  describe "visit" do
    it "renders" do
      get patron_root_path
      response.status.should be(200)
    end
  end
end
