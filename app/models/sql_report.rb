class SqlReport < ActiveRecord::Base
  validates :name, :sql, :presence => true
  validates :name, :uniqueness => true

  # Returns a string containing a brief, general description of this class/model.
  def self.class_description
    return "Custom Report is a SQL query with a name and description, saved to the database for repeated use."
  end
 
end
