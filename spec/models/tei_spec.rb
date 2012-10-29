require 'spec_helper'

describe Tei do
  it "should return a Tei object" do
    Tei.new.should be_an_instance_of(Tei)
  end

  it "can be saved successfully" do
    Tei.create.should be_persisted
  end
end
