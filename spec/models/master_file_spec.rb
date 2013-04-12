require 'spec_helper'

describe MasterFile do
  it 'is invalid without a filename' do
    mf = FactoryGirl.create(:master_file)
    mf.should validate_presence_of(:filename)
  end
end
