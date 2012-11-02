require 'spec_helper'

describe Tei do
  it "should return a Tei object" do
    Tei.new.should be_an_instance_of(Tei)
  end

  it "can be saved successfully" do
    Tei.create.should be_persisted
  end
end

describe "Tei validation" do
  it "can have a title" do
    t=Tei.new
    t.title="Robert E. Lee to C.C. Lee Esq. May 8th, 1830"
    t.availability_policy=AvailabilityPolicy.find(1)
    t.filename="some/path/to/a/file"
    t.valid?.should be_true
  end
end
