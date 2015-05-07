class UnitImportSource < ActiveRecord::Base
  belongs_to :unit
 
  validates :unit_id, :presence => true
  validates :unit, :presence => {
    :message => "association with this Unit is no longer valid because the Unit object no longer exists."
  }

  # Returns a string containing a brief, general description of this
  # class/model.
  def UnitImportSource.class_description
    return "Unit Import Source contains the source document used to import unit-related data into the system."
  end
end
