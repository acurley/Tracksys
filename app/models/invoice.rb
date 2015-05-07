class Invoice < ActiveRecord::Base

  belongs_to :order, :counter_cache => true

  validates :order_id, :presence => true
  validates :order, :presence => {
    :message => "association with this Order is no longer valid because it does not exist."
  }

  delegate :date_order_approved, :date_customer_notified,
    :to => :order, :allow_nil => true, :prefix => true

  def self.outstanding_as_of(date=0.days.ago)
    if ! date.kind_of?(ActiveSupport::TimeWithZone)
      logger.error "#{self.name}#outstanding_as_of Expecting ActiveSupport::TimeWithZone as argument. Got #{date.class} instead"
      date=0.days.ago
    end
    where("date_fee_paid is NULL").where("date_invoice < ?", date)
  end
  def self.second_notice_as_of(date=0.days.ago)
    if ! date.kind_of?(ActiveSupport::TimeWithZone)
      logger.error "#{self.name}#second_notice_as_of Expecting ActiveSupport::TimeWithZone as argument. Got #{date.class} instead"
      date=0.days.ago
    end
    where("date_fee_paid is NULL").where("date_invoice < ?", date).where("date_second_notice_sent is not NULL")
  end

  scope :past_due, outstanding_as_of(30.days.ago)
  scope :notified_past_due, second_notice_as_of(30.days.ago)
  scope :permanent_nonpayment, lambda { where("permanent_nonpayment != 0") } 

  delegate :customer, to: :order, prefix: true
  delegate :fee_actual, to: :order, prefix: true
end
