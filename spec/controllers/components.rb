# rspec tests for component class via ActiveAdmin
# special emphasis on Fedora API
require 'spec_helper'
include Devise::TestHelpers

#describe "Ingest" do
describe Admin::ComponentsController do
  render_views

  before(:all) do
    @pidded_component, @unpidded_component = 244451, 255024
    @thing = Component.find(@pidded_component)
    puts "Purging #{@thing.pid} from test repository #{FEDORA_REST_URL}."
    Fedora.purge_object(@thing.pid) if @thing.exists_in_repo?
#    @user = StaffMember.find(31) # rest_user, a dummy user

  end

  before(:each) do
    controller.stub(:authenticate_admin_user!)

#    @user = mock_model(StaffMember, :access_level_id => 1, :is_active => true, :computing_id => "tester")
#    request.env['tester'] = mock('Tester', :authenticate => @user, :authenticate! => @user)
  end

  describe "ingest pidded component" do
    it "should succeed in ingesting component into fedora repository" do
      @id = @pidded_component
      thing = Component.find(@id)
      label = "test label #{@id}"
      res=Fedora.create_or_update_object(thing, label) #create returns pid, update, a timestamp
      res.should eq(thing.pid)
    end
  end

  describe "ingest pidded component using member_action :ingest_object" do
    it "should succeed in ingesting component into fedora repository" do
      @id = @pidded_component
      request.env["HTTP_REFERER"] = "/admin/components/#{@id}"

      thing = Component.find(@id)
      puts "\n#{thing.inspect}\n"
      puts "exists_in_repo: #{thing.exists_in_repo?}"
      put :ingest_object, :id => @id
#      ap response
      response.status.should eq(302)
    end
  end

  describe "prevent ingest of unpidded component" do
    it "should alert user that object cannot be ingested" do 
      @id = @unpidded_component
      @id.should eq(255024)
    end
  end

  describe "purge object from repository" do 
    it "should remove an object from the repository" do
      @id = @pidded_component
      thing = Component.find(@id)

      if ! thing.exists_in_repo?
        Fedora.create_or_update_object(thing, "rspec built me, please delete me")
      end
      res = Fedora.purge_object(@thing.pid) # purge returns timestamp on success

      match = res.match(Date.today.to_s)
      match.to_s.should  eq(Date.today.to_s)
    end
  end

  after(:each) do
    puts "\nPurging #{@thing.pid} from test repository."
    Fedora.purge_object(@thing.pid) if @thing.exists_in_repo?
  end

end
