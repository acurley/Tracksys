class Archive < ActiveRecord::Base
  has_many :units
  has_many :master_files, :through => :units
  
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false} # 'HSM' and 'Hsm' should be considered the same.
  
  before_destroy :destroyable?
  
  default_scope :order => :name
 
  # Returns a string containing a brief, general description of this
  # class/model.
  def Archive.class_description
    return 'Archive indicates the long-term storage location of a Unit.'
  end
  
  # Returns a boolean value indicating whether it is safe to delete
  # this Archive from the database. Returns +false+ if this record
  # has dependent records in other tables, namely associated Unit
  # records.
  #
  # This method is public but is also called as a +before_destroy+ callback.
  def destroyable?
   return false unless units.any?
  end
end
