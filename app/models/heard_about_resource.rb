class HeardAboutResource < ActiveRecord::Base

  has_many :units
  has_many :master_files, :through => :units
  has_many :orders, :through => :units
  has_many :customers, :through => :orders

  before_save do
    self.is_approved = 0 if self.is_approved.nil?
    self.is_internal_use_only = 0 if self.is_internal_use_only.nil?
  end
  
  default_scope :order => :description
  
  scope :approved, where(:is_approved => true)
  scope :for_request_form, where(:is_approved => true).where(:is_internal_use_only => false)
  scope :internal_use_only, where(:is_internal_use_only => true)
  scope :not_approved, where(:is_approved => false)
  scope :publicly_available, where(:is_internal_use_only => false)
 
  # Necessary for Active Admin to poplulate pulldown menu
  alias_attribute :name, :description  
  
end
