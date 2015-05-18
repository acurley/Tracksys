class DvdDeliveryLocation < ActiveRecord::Base
  has_many :orders

  validates :name, :email_desc, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :destroyable?

  # Returns a string containing a brief, general description of this
  # class/model.
  def self.class_description
    "DVD Delivery Location provides a physical location for the pickup of completed orders.  A description of the location, including directions, hours, etc. can be included in the 'email_desc' field and may be included in emails sent to to the customer."
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
