require "#{Hydraulics.models_dir}/customer"

class Customer
  include Rails.application.routes.url_helpers # neeeded for _path helpers to work in models
  accepts_nested_attributes_for :primary_address
  accepts_nested_attributes_for :billable_address, :reject_if => :all_blank

  after_update :fix_updated_counters
  
  has_paper_trail

  #------------------------------------------------------------------
  # relationships
  #------------------------------------------------------------------
 
  #------------------------------------------------------------------
  # validations
  #------------------------------------------------------------------
  validates :academic_status_id, :presence => true
 
  #------------------------------------------------------------------
  # callbacks
  #------------------------------------------------------------------

  #------------------------------------------------------------------
  # scopes
  #------------------------------------------------------------------  
 
  #------------------------------------------------------------------
  # public class methods
  #------------------------------------------------------------------
 
  #------------------------------------------------------------------
  # public instance methods
  #------------------------------------------------------------------
  def external?
    self.academic_status.name == "Non-UVA"
  end

  def admin_permalink
    admin_customer_path(self)
  end

  alias_attribute :name, :full_name

end
