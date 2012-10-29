class Tei
  include Pidable

  #------------------------------------------------------------------
  # relationships
  #------------------------------------------------------------------
  has_and_belongs_to_many :bibls

  #------------------------------------------------------------------
  # validations
  #------------------------------------------------------------------
  validates :filename, :unit_id, :filesize, :presence => true
  validates :availability_policy, :presence => {
    :if => 'self.availability_policy_id',
    :message => "association with this AvailabilityPolicy is no longer valid because it no longer exists."
  }
  validates :indexing_scenario, :presence => {
    :if => 'self.indexing_scenario_id',
    :message => "association with this IndexingScenario is no longer valid because it no longer exists."
  }
  validates :use_right, :presence => {
    :if => 'self.use_right_id',
    :message => "association with this Use is no longer valid because it no longer exists."
  }
  #------------------------------------------------------------------
  # callbacks
  #------------------------------------------------------------------

  #------------------------------------------------------------------
  # scopes
  #------------------------------------------------------------------  
  # scope :in_digital_library, where("teis.date_dl_ingest is not null").order("teis.date_dl_ingest ASC")
  # scope :not_in_digital_library, where("teis.date_dl_ingest is null")
  # default_scope :include => [:availability_policy, :component, :indexing_scenario, :unit, :use_right]

  #------------------------------------------------------------------
  # public class methods
  #------------------------------------------------------------------
 
  #------------------------------------------------------------------
  # public instance methods
  #------------------------------------------------------------------
end