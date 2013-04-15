require 'spec_helper'

describe Customer do
  before do
    @customer = FactoryGirl.build(:customer)
  end

  it { should validate_presence_of :academic_status_id }

  it "should have an alias of name for fullname" do
    @customer.full_name.should == @customer.name
  end

  it "should have an internal and external status" do
    @customer.external?.should be_false
    external_customer = FactoryGirl.build(:external_customer)
    external_customer.external?.should be_true
  end
end
