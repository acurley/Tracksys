class Request < Order
  belongs_to :customer, inverse_of: :requests

  accepts_nested_attributes_for :units
  accepts_nested_attributes_for :customer

  validates :is_approved, inclusion: { in: [false] }
  validates :units, presence: {
    message: 'are required.  Please add at least one item to your request.'
  }

  validates_presence_of :customer

  def self.class_description
    'A Request is an Order that has not been approved for digitization.'
  end
end
