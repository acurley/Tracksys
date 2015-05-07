class IntendedUse < ActiveRecord::Base
  default_scope :order => :description

  # Necessary for Active Admin to poplulate pulldown menu
  alias_attribute :name, :description  
  
  has_many :units
  
  validates :description, :presence => true

  scope :interal_use_only, where(:is_internal_use_only => true)
  scope :external_use, where(:is_internal_use_only => false)

  before_destroy :destroyable?

  before_save do
    # boolean fields cannot be NULL at database level
    self.is_internal_use_only = 0 if self.is_internal_use_only.nil?
    self.is_approved = 0          if self.is_approved.nil?
  end

  # Returns a string containing a brief, general description of this
  # class/model.
  def IntendedUse.class_description
    return "Intended Use indicates how the Customer intends to use the digitized resource (Unit)."
  end

  # Returns a boolean value indicating whether it is safe to delete this record
  # from the database. Returns +false+ if this record has dependent records in
  # other tables, namely associated Unit records.
  #
  # This method is public but is also called as a +before_destroy+ callback.
  def destroyable?
    if not units.empty?
      return false
    end
    return true
  end
end
