class Bibl < ActiveRecord::Base
  include Pidable

  belongs_to :availability_policy, counter_cache: true
  belongs_to :indexing_scenario, counter_cache: true
  belongs_to :use_right, counter_cache: true
  belongs_to :index_destination, counter_cache: true

  has_and_belongs_to_many :legacy_identifiers
  has_and_belongs_to_many :components

  has_many :agencies, through: :orders
  has_many :automation_messages, as: :messagable, dependent: :destroy
  has_many :customers, through: :orders, uniq: true
  has_many :master_files, through: :units
  has_many :orders, through: :units, uniq: true
  has_many :units

  scope :approved, where(is_approved: true)
  scope :dpla, where(dpla: true)
  scope :in_digital_library, where('bibls.date_dl_ingest is not null').order('bibls.date_dl_ingest DESC')
  scope :not_in_digital_library, where('bibls.date_dl_ingest is null')
  scope :not_approved, where(is_approved: false)
  scope :has_exemplars, where('exemplar is NOT NULL')
  scope :need_exemplars, where('exemplar is NULL')

  delegate :id, :email,
           to: :customers, allow_nil: true, prefix: true

  validates :availability_policy, presence: {
    if: 'self.availability_policy_id',
    message: 'association with this AvailabilityPolicy is no longer valid because it no longer exists.'
  }
  validates :indexing_scenario, presence: {
    if: 'self.indexing_scenario_id',
    message: 'association with this IndexingScenario is no longer valid because it no longer exists.'
  }

  before_save do
    # boolean fields cannot be NULL at database level
    self.is_approved = 0 if is_approved.nil?
    self.is_collection = 0 if is_collection.nil?
    self.is_in_catalog = 0 if is_in_catalog.nil?
    self.is_manuscript = 0 if is_manuscript.nil?
    self.is_personal_item = 0 if is_personal_item.nil?
    self.discoverability = 1 if discoverability.nil? # For Bibl objects, the default value is 1 (i.e. is discoverable)

    # get pid
    if pid.blank?
      begin
        self.pid = AssignPids.get_pid
      rescue Exception => e
        # ErrorMailer.deliver_notify_pid_failure(e) unless @skip_pid_notification
      end
    end

    # Moved from after_initialize in order to make compliant with 2.3.8
    if is_in_catalog.nil?
      # set default value
      if self.is_personal_item?
        self.is_in_catalog = false
      else
        # held by Library; default to assuming it's in Library catalog
        self.is_in_catalog = true
      end
    end
  end

  before_destroy :destroyable?

  after_update :fix_updated_counters

  CREATOR_NAME_TYPES = %w(corporate personal)
  YEAR_TYPES = %w(copyright creation publication)
  GENRES = ['abstract or summary', 'art original', 'art reproduction', 'article', 'atlas', 'autobiography', 'bibliography', 'biography', 'book', 'catalog', 'chart', 'comic strip', 'conference publication', 'database', 'dictionary', 'diorama', 'directory', 'discography', 'drama', 'encyclopedia', 'essay', 'festschrift', 'fiction', 'filmography', 'filmstrip', 'finding aid', 'flash card', 'folktale', 'font', 'game', 'government publication', 'graphic', 'globe', 'handbook', 'history', 'hymnal', 'humor, satire', 'index', 'instruction', 'interview', 'issue', 'journal', 'kit', 'language instruction', 'law report or digest', 'legal article', 'legal case and case notes', 'legislation', 'letter', 'loose-leaf', 'map', 'memoir', 'microscope slide', 'model', 'motion picture', 'multivolume monograph', 'newspaper', 'novel', 'numeric data', 'offprint', 'online system or service', 'patent', 'periodical', 'picture', 'poetry', 'programmed text', 'realia', 'rehearsal', 'remote sensing image', 'reporting', 'review', 'script', 'series', 'short story', 'slide', 'sound', 'speech', 'statistics', 'survey of literature', 'technical drawing', 'technical report', 'thesis', 'toy', 'transparency', 'treaty', 'videorecording', 'web site']
  RESOURCE_TYPES = ['text', 'cartographic', 'notated music', 'sound recording', 'sound recording-musical', 'sound recording-nonmusical', 'still image', 'moving image', 'three dimensional object', 'software, multimedia', 'mixed material']

  VIRGO_FIELDS = %w(title creator_name creator_name_type call_number catalog_key barcode copy date_external_update location citation year year_type location copy title_control date_external_update cataloging_source)
  # Create and manage a Hash that contains the SIRSI location codes and their human readable values for citation purposes
  LOCATION_HASH = {
    'ALD-STKS' => 'Alderman Library, University of Virginia, Charlottesville, VA.',
    'ASTRO-STKS' => 'Astronomy Library, University of Virginia, Charlottesville, VA.',
    'BARR-STKS' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'CABELJR' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'DEC-IND-RM' => 'Albert H. Small Declaration of Independence Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'FA-FOLIO' => 'Fiske Kimball Fine Arts Library, University of Virginia, Charlottesville, VA.',
    'FA-OVERSIZE' => 'Fiske Kimball Fine Arts Library, University of Virginia, Charlottesville, VA.',
    'FA-STKS' => 'Fiske Kimball Fine Arts Library, University of Virginia, Charlottesville, VA.',
    'GEOSTAT' => 'Alderman Library, University of Virginia, Charlottesville, VA.',
    'HS-CABELJR' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'HS-RAREOVS' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'HS-RARESHL' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'HS-RAREVLT' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'IVY-BOOK' => 'Ivy Annex, University of Virginia, Charlottesville, VA.',
    'IVY-STKS' => 'Ivy Annex, University of Virginia, Charlottesville, VA.',
    'IVYANNEX' => 'Ivy Annex, University of Virginia, Charlottesville, VA.',
    'LAW-IVY' => 'Law Library, University of Virginia, Charlottesville, VA.',
    'MCGR-VLTFF' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'RAREOVS' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'RARESHL' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'RAREVLT' => 'Health Sciences Library, University of Virginia, Charlottesville, VA.',
    'SC-ARCHV' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-ARCHV-X' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-F' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-FF' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-M' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-RM' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-ST' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-X' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-XF' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARR-XZ' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-BARRXFF' => 'Clifton Waller Barrett Library of American Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-GARN-F' => 'Garnett Family Library, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-GARN-RM' => 'Garnett Family Library, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-IVY' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGR-F' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGR-FF' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGR-RM' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGR-ST' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGR-X' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGR-XF' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGR-XZ' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-MCGRXFF' => 'Tracy W. McGregor Library of American History, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-REF' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-REF-F' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-SCOTT' => 'Marion duPont Scott Sporting Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-SCOTT-F' => 'Marion duPont Scott Sporting Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-SCOTT-M' => 'Marion duPont Scott Sporting Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-SCOTT-X' => 'Marion duPont Scott Sporting Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-SCOTTFF' => 'Marion duPont Scott Sporting Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-SCOTTXF' => 'Marion duPont Scott Sporting Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-SCOTTXZ' => 'Marion duPont Scott Sporting Collection, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-D' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-EF' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-F' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-FF' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-M' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-X' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-XF' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKS-XZ' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-STKSXFF' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-TATUM' => 'Marvin Tatum Collection of Contemporary Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-TATUM-F' => 'Marvin Tatum Collection of Contemporary Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-TATUM-M' => 'Marvin Tatum Collection of Contemporary Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-TATUM-X' => 'Marvin Tatum Collection of Contemporary Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-TATUMFF' => 'Marvin Tatum Collection of Contemporary Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-TATUMXF' => 'Marvin Tatum Collection of Contemporary Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SC-TATUMXZ' => 'Marvin Tatum Collection of Contemporary Literature, Special Collections, University of Virginia, Charlottesville, VA.',
    'SPEC-COLL' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'STACKS' => 'Special Collections, University of Virginia, Charlottesville, VA.',
    'Reading Room' => 'Special Collection, University of Virginia, Charlottesville, VA.'
  }

  alias_attribute :name, :title

  # Although many Bibl records have citations provided through the MARC record, many do not
  # (especially those which lack a MARC record or are otherwise not cataloged in VIRGO).  As
  # a result, this method will impose some general order on the act of creating citations where
  # needed and rely upon the canonical citation when present.
  def get_citation
    if citation
      return citation
    else
      citation = ''
      citation << "#{cleanedup_title}.  " if title
      citation << "#{call_number}.  " if call_number
      if location
        begin
          citation << "#{LOCATION_HASH.fetch(location)}"
        rescue
          citation << 'Special Collections, University of Virginia, Charlottesville, VA'
        end
      else
        citation << 'Special Collections, University of Virginia, Charlottesville, VA'
      end
      return citation
    end
  end

  # For the purposes of citations, run the title through some manipulation.
  def cleanedup_title
    # Remove trailing periods.
    if title.match(/\.$/)
      return title.chop
    else
      return title
    end
  end

  def physical_virgo_url
    "#{VIRGO_URL}/#{catalog_key}"
  end

  def dl_virgo_url
    "#{VIRGO_URL}/#{pid}"
  end

  def fedora_url
    "#{FEDORA_REST_URL}/objects/#{pid}"
  end

  def solr_url(url = SOLR_URL)
    "#{url}/select?q=id:\"#{pid}\""
  end
end
