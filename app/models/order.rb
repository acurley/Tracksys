class Order < ActiveRecord::Base
  include BuildOrderPDF

  ORDER_STATUSES = %w[completed requested deferred canceled approved]

  belongs_to :agency, :counter_cache => true
  belongs_to :customer, :counter_cache => true, :inverse_of => :orders
  belongs_to :dvd_delivery_location, :counter_cache => true
  
  has_many :automation_messages, :as => :messagable, :dependent => :destroy
  has_many :bibls, :through => :units
  has_many :invoices, :dependent => :destroy
  has_many :master_files, :through => :units
  has_many :units, :inverse_of => :order
  has_many :heard_about_resources, :through => :units, :uniq => true

  has_one :academic_status, :through => :customer
  has_one :department, :through => :customer
  has_one :heard_about_service, :through => :customer
  has_one :primary_address, :through => :customer
  has_one :billable_address, :through => :customer

  delegate :full_name, :last_name, :first_name,
    :to => :customer, :allow_nil => true, :prefix => true
  delegate :name, 
    :to => :agency, :allow_nil => true, :prefix => true

  scope :complete, where("date_archiving_complete is not null")
  scope :deferred, where("order_status = 'deferred'")
  scope :in_process, where("date_archiving_complete is null").where("order_status = 'approved'")
  scope :awaiting_approval, where("order_status = 'requested'")
  scope :approved, where("order_status = 'approved'")
  scope :ready_for_delivery, where("`orders`.email is not null").where(:date_customer_notified => nil)
  scope :has_dvd_delivery, where("dvd_delivery_location_id IS NOT NULL")
  scope :recent, 
    lambda {|limit=5|
      order('date_request_submitted DESC').limit(limit)
    }
  scope :unpaid, where("fee_actual > 0").joins(:invoices).where('`invoices`.date_fee_paid IS NULL').where('`invoices`.permanent_nonpayment IS false').where('`orders`.date_customer_notified > ?', 2.year.ago).order('fee_actual desc')
  default_scope :include => [:agency]

  serialize :email

  after_update :fix_updated_counters

  scope :from_fine_arts, joins(:agency).where("agencies.name" => "Fine Arts Library")
  scope :not_from_fine_arts, where('agency_id != 37 or agency_id is null')

  validates :date_due, :date_request_submitted, :presence => {
    :message => 'is required.'
  }
  validates_presence_of :customer

  validates :dvd_delivery_location, :presence => {
    :if => 'self.dvd_delivery_location_id',
    :message => "assocation with this DvdDeliveryLocation is no longer valid because the DvdDeliveryLocation object no longer exists."
  }
  validates :order_title, :uniqueness => true, :allow_blank => true
  
  validates :fee_estimated, :fee_actual, :numericality => {:greater_than_or_equal_to => 0, :allow_nil => true}

  validates :order_status, :inclusion => { :in => ORDER_STATUSES, 
    :message => 'must be one of these values: ' + ORDER_STATUSES.join(", ")}
            
  validates_datetime :date_request_submitted
  
  validates_date :date_due, :on => :update
  validates_date :date_due, :on => :create, :on_or_after => 28.days.from_now, :if => 'self.order_status == "requested"'
  
  validates_datetime :date_order_approved,
                    :date_deferred,
                    :date_canceled,
                    :date_permissions_given,
                    :date_started,
                    :date_archiving_complete,
                    :date_patron_deliverables_complete,
                    :date_customer_notified,
                    :date_finalization_begun,
                    :date_fee_estimate_sent_to_customer,
                    :allow_blank => true

  # validates that an order_status cannot equal approved if any of it's Units.unit_status != "approved" || "canceled"
  validate :validate_order_approval, :on => :update, :if => 'self.order_status == "approved"'
                    
  # Validate data that could be coming in from the request form such that < and > are not
  # allowed in the text to prevent cross site scripting.
  validates :order_title, :entered_by, :special_instructions, :xss => true           
 
  before_destroy :destroyable?
  
  before_save do
    # boolean fields cannot be NULL at database level
    self.is_approved = 0 if self.is_approved.nil? 
    self.is_approved = 1 if self.order_status == 'approved'
  end

  # Returns a string containing a brief, general description of this
  # class/model.
  def Order.class_description
    return 'Order represents an order for digitization, placed by a Customer and made up of one or more Units.'
  end

  def Order.entered_by_description
    return "ID of person who filled out the public request form on behalf of the Customer."
  end
  
  #------------------------------------------------------------------
  # public instance methods
  #------------------------------------------------------------------
  # Returns a boolean value indicating whether the Order is active, which is
  # true unless the Order has been canceled or deferred.
  def active?
    if order_status == 'canceled' or order_status == 'deferred'
      return false
    else
      return true
    end
  end
  
  # Returns a boolean value indicating whether the Order is approved
  # for digitization ("order") or not ("request").
  def approved?
    if order_status == 'approved'
      return true
    else
      return false
    end
  end

  def canceled?
    if order_status == 'canceled'
      return true
    else
      return false
    end
  end

  # Returns a boolean value indicating whether it is safe to delete
  # this Order from the database. Returns +false+ if this record has
  # dependent records in other tables, namely associated Unit or
  # Invoice records.
  #
  # This method is public but is also called as a +before_destroy+ callback.
  def destroyable?               
    if units? || invoices?        
      return false 
    else
      return true
    end  
  end
  
  # Returns a boolean value indicating whether this Order has
  # associated Invoice records.
  def invoices?
    return invoices.any?
  end

  # Returns units belonging to current order that are not ready to proceed with digitization and would prevent an order from being approved.
  # Only units whose unit_status = 'approved' or 'canceled' are removed from consideration by this method.
  def has_units_being_prepared
    units_beings_prepared = Unit.where(:order_id => self.id).where('unit_status = "unapproved" or unit_status = "condition" or unit_status = "copyright"')
    return units_beings_prepared
  end

  # A validation callback which returns to the Order#edit view the IDs of Units which are preventing the Order from being approved because they 
  # are neither approved or canceled.
  def validate_order_approval
    units_beings_prepared = self.has_units_being_prepared
    if not units_beings_prepared.empty?
      errors[:order_status] << "cannot be set to approved because units #{units_beings_prepared.map(&:id).join(', ')} are neither approved nor canceled"
    end
  end
  
  # Returns a boolean value indicating whether this Order has
  # associated Unit records.
  def units?
    return units.any?
  end
  
  def self.due_within(timespan)
    if ! timespan.kind_of?(ActiveSupport::TimeWithZone)
      logger.error "#{self.name}#due_within expecting ActiveSupport::TimeWithZone as argument.  Got #{timespan.class} instead" 
      timespan = 1.week.from_now
    end
    if Time.now.to_date == timespan.to_date
      where("date_due = ?", Date.today)
    elsif Time.now > timespan
      where("date_due < ?", Date.today).where("date_due > ?", timespan)
    else
      where("date_due > ?", Date.today).where("date_due < ?", timespan)
    end
  end
  def self.overdue_as_of(date=0.days.ago)
    if ! date.kind_of?(ActiveSupport::TimeWithZone)
      logger.error "#{self.name}#overdue_as_of Expecting ActiveSupport::TimeWithZone as argument. Got #{date.class} instead"
      date=0.days.ago
    end
    where("date_request_submitted > ?", date - 1.years ).where("date_due < ?", date).where("date_deferred is NULL").where("date_canceled is NULL").where("order_status != 'canceled'").where("date_patron_deliverables_complete is NULL").where("order_status != 'deferred'").where("order_status != 'completed'")
  end

  alias_attribute :name, :id

  scope :overdue, overdue_as_of(0.days.ago)
  scope :due_today, due_within(0.day.from_now)
  scope :due_in_a_week, due_within(1.week.from_now)
  scope :complete, where("date_archiving_complete is not null OR order_status = 'completed'")


  # Determine if any of an Order's Units are not 'approved' or 'cancelled'
  def ready_to_approve?
    status = self.units.map(&:unit_status) & ['condition', 'copyright', 'unapproved']
    return status.empty?
  end

  def title
    if order_title
      order_title
    elsif units.first.respond_to?(:bibl_id?)
      if units.first.bibl_id?
        units.first.bibl.title
      else
        nil
      end
    else
      nil
    end
  end
  
  # Processor information
  require 'activemessaging/processor'
  include ActiveMessaging::MessageSender

  def approve_order
    message = ActiveSupport::JSON.encode( {:order_id => self.id})
    publish :update_order_status_approved, message
  end

  def cancel_order
    message = ActiveSupport::JSON.encode( {:order_id => self.id} )
    publish :update_order_status_canceled, message
  end

  def check_order_ready_for_delivery
    message = ActiveSupport::JSON.encode( {:order_id => self.id})
    publish :check_order_ready_for_delivery, message
  end

  def create_order_pdf
    message = ActiveSupport::JSON.encode( {:order_id => self.id, :fee => self.fee_actual.to_i})
    publish :create_order_pdf, message
  end

  def qa_order_data
    message = ActiveSupport::JSON.encode({:order_id => self.id})
    publish :qa_order_data, message
  end

  def send_fee_estimate_to_customer(computing_id)
    @user = StaffMember.find_by_computing_id(computing_id) 
    @first_name = @user.first_name
    message = ActiveSupport::JSON.encode( {:order_id => self.id, :first_name => @first_name})
    publish :send_fee_estimate_to_customer, message
  end

  def send_order_email
    message = ActiveSupport::JSON.encode( {:order_id => self.id})
    publish :send_order_email, message
  end  # End processor methods
end
