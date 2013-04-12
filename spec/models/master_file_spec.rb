require 'spec_helper'

describe MasterFile do
  before do
    @master_file = FactoryGirl.build(:master_file)
  end

  it 'is invalid without a filename' do
    FactoryGirl.build(:master_file, filename: nil).should_not be_valid
  end

  it 'is invalid with no filesize' do
    FactoryGirl.build(:master_file, filesize: nil).should_not be_valid
  end

  it "should be destroyable, if it has no dependent records" do
    FactoryGirl.build(:master_file).should be_destroyable
  end
end
