# rspec tests for component class via ActiveAdmin
# special emphasis on Fedora API
require 'spec_helper'
@testdir="tmp"

describe "Ingest" do

  before(:all) do
    @pidded_component, @unpidded_component = 244451, 255024
    @thing = Component.find(@pidded_component)
    puts "Purging #{@thing.pid} from test repository."
    Fedora.purge_object(@thing.pid) if @thing.exists_in_repo?
  end

  describe "ingest pidded component" do
    it "should succeed in ingesting component into fedora repository" do
      @id = @pidded_component
      @id.should eq(244451)
    end
  end

  describe "prevent ingest of unpidded component" do
    it "should alert user that object cannot be ingested" do 
      @id = @unpidded_component
      @id.should eq(255024)
    end
  end

  after(:all) do
    puts "\nPurging #{@thing.pid} from test repository."
    Fedora.purge_object(@thing.pid) if @thing.exists_in_repo?
  end

end
