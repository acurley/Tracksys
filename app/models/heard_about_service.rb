class HeardAboutService < ActiveRecord::Base

  has_many :customers
  has_many :orders, :through => :customers
  has_many :units, :through => :orders
  has_many :master_files, :through => :units

  before_save do
    self.is_approved = 0 if self.is_approved.nil?
    self.is_internal_use_only = 0 if self.is_internal_use_only.nil?
  end

  default_scope :order => :description
  scope :approved, where(:is_approved => true)
  scope :for_request_form, where(:is_approved => true).where(:is_internal_use_only => false)
  scope :not_approved, where(:is_approved => false)
  scope :internal_use_only, where(:is_internal_use_only => true)
  scope :publicly_available, where(:is_internal_use_only => false)

  # Necessary for Active Admin to poplulate pulldown menu
  alias_attribute :name, :description
  
end
