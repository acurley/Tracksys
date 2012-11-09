class Tei < ActiveRecord::Base
  include Pidable

  #------------------------------------------------------------------
  # relationships
  #------------------------------------------------------------------
  has_and_belongs_to_many :bibls
  belongs_to :availability_policy, :counter_cache => true
  belongs_to :indexing_scenario, :counter_cache => true
  belongs_to :use_right, :counter_cache => true

  has_and_belongs_to_many :legacy_identifiers
  
  has_many :automation_messages, :as => :messagable, :dependent => :destroy

  #------------------------------------------------------------------
  # validations
  #------------------------------------------------------------------
  validates :filename, :presence => true
  # validates :availability_policy, :presence => {
  #   :if => 'self.availability_policy_id',
  #   :message => "association with this AvailabilityPolicy is no longer valid because it no longer exists."
  # }
  # validates :indexing_scenario, :presence => {
  #   :if => 'self.indexing_scenario_id',
  #   :message => "association with this IndexingScenario is no longer valid because it no longer exists."
  # }
  # validates :use_right, :presence => {
  #   :if => 'self.use_right_id',
  #   :message => "association with this Use is no longer valid because it no longer exists."
  # }
  #------------------------------------------------------------------
  # callbacks
  #------------------------------------------------------------------
  before_save do    
    # boolean fields cannot be NULL at database level
    # self.is_approved = 0 if self.is_approved.nil?
    # self.is_collection = 0 if self.is_collection.nil?
    # self.is_in_catalog = 0 if self.is_in_catalog.nil?
    # self.is_manuscript = 0 if self.is_manuscript.nil?
    # self.is_personal_item = 0 if self.is_personal_item.nil?
    # self.discoverability = 1 if self.discoverability.nil? # For Bibl objects, the default value is 1 (i.e. is discoverable)
    
    # catalog_key is a local copy of a single Bibl's key
    if self.catalog_key.blank? && self.bibls != []
      begin
        self.catalog_key = self.bibls.first.catalog_key
      rescue Exception => e
        warn "Execption #{e.inspect} was raised."
      end
    end

    # get pid
    if self.pid.blank?
      begin
        self.pid = AssignPids.get_pid
      rescue Exception => e
        #ErrorMailer.deliver_notify_pid_failure(e) unless @skip_pid_notification
      end
    end
  end


  #------------------------------------------------------------------
  # scopes
  #------------------------------------------------------------------  
  # scope :in_digital_library, where("teis.date_dl_ingest is not null").order("teis.date_dl_ingest ASC")
  # scope :not_in_digital_library, where("teis.date_dl_ingest is null")
  # default_scope :include => [:availability_policy, :component, :indexing_scenario, :unit, :use_right]

  #------------------------------------------------------------------
  # public class methods
  #------------------------------------------------------------------
 
  #------------------------------------------------------------------
  # public instance methods
  #------------------------------------------------------------------
  def in_dl?
    return self.date_dl_ingest?
  end

  def in_catalog?
    return self.catalog_key?
  end

  def name
    return self.filename
  end

  def physical_virgo_url
    return "#{VIRGO_URL}/#{self.catalog_key}"
  end

  def dl_virgo_url
    return "#{VIRGO_URL}/#{self.pid}"
  end

  def fedora_url
    return "#{FEDORA_REST_URL}/objects/#{self.pid}"
  end
end