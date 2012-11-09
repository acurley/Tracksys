require 'spec_helper'

describe Tei do
  it "should return a Tei object" do
    Tei.new.should be_an_instance_of(Tei)
  end

  it "can be saved successfully" do
    Tei.create(:filename => "foo").should be_persisted
  end
end

describe "Tei validation" do
  it "can have a title" do
    Tei.create(:filename => "foo", :title => "Robert E. Lee to C.C. Lee Esq. May 8th, 1830").should be_valid
  end
end
