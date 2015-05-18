class Component < ActiveRecord::Base
  has_ancestry
  include Pidable
  include ExportIviewXML

  belongs_to :availability_policy, counter_cache: true
  belongs_to :component_type, counter_cache: true
  belongs_to :indexing_scenario, counter_cache: true
  belongs_to :use_rights, counter_cache: true

  has_many :automation_messages, as: :messagable, dependent: :destroy
  has_many :master_files
  has_many :image_master_files, class_name: 'MasterFile', conditions: "tech_meta_type = 'image'"

  has_and_belongs_to_many :bibls
  has_and_belongs_to_many :containers
  has_and_belongs_to_many :legacy_identifiers

  validates :component_type, presence: true
  validates :component_type, presence: {
    message: 'association with this ComponentType is no longer valid.'
  }

  before_save :copy_parent_reference
  before_save :cache_ancestry

  # Intended as a before_save callback, will save to a Component object:
  # 1.  A pids_depth cache so a hierarchy of pids for each component is available
  # 2.  An ead_id_atts depth cache for legacy ids on each Component derived from an EAD guide.
  def cache_ancestry
    self.pids_depth_cache = path.map(&:pid).join('/')
    self.ead_id_atts_depth_cache = path.map(&:ead_id_att).join('/')
  end

  # Using ancestry gem, the "parent" information for a Component lives in the ancestry attribute.
  # In migrating information during the Tracksys3 rollout, we need a way to translate the legacy attribute
  # parent_componnet_id to the ancestry parent method.  The following method provides that facility.
  def copy_parent_reference
    if parent_component_id > 0 && parent.nil?
      self.parent = Component.find(parent_component_id)
    end
  end

  # overriding method because data lives in several places
  def level
    if @level
      @level
    elsif component_type
      component_type.name
    else
      nil
    end
  end

  # At this time there is no definitive field that can be used for "naming" purposes.
  # There are several candidates (title, content_desc, label) and until we make
  # a definitive choice, we must rely upon an aritifical method to provide the string.
  #
  # Given the inconsistencies of input data, all newlines and sequences of two or more spaces
  # will be substituted.
  def name
    value = ''
    if !title.blank?
      value = title
    elsif !content_desc.blank?
      value = content_desc
    elsif !label.blank?
      value = label
    elsif !date.blank?
      value = date
    else
      value = id # Everything has an id, so it is the LCD.
    end
    value.to_s.strip.gsub(/\n/, ' ').gsub(/  +/, ' ')
  end

  # For the purposes of digitization, student workers need access to as much of the metadata available
  # in the Component class as possible.  The 'name' method does not provide enough information in some
  # circumstances.  In the circumstances where a Component has both a title and content_desc, pull both.
  # Otherwise, use the default name method.
  def iview_description
    value = ''
    if title && content_desc
      value = "#{title} - #{content_desc}"
    else
      value = name
    end
    value.strip.gsub(/\n/, ' ').gsub(/  +/, ' ')
  end

  # Returns a count of all MasterFiles belonging to both this component (i.e. self) and its children.
  # The count is used for component views.
  #
  # Dependent on ancestry gem.
  def descendant_master_file_count
    c = 0
    # children = Component.where(:parent_id => self.id).select(:id) # Get the ids of all children of self.  Any other piece of info is extraneous.
    children = Component.where(id: child_ids).select(:id).select(:ancestry)
    c += MasterFile.where(component_id: id).size # add self.master_files
    until children.empty?
      c += MasterFile.where(component_id: children.map(&:id)).size
      children = Component.where(id: children.map(&:child_ids)).select(:id).select(:ancestry)
    end

    c
  end

  # Returns an array of all MasterFiles belonging to this component (i.e. self) and its children.
  #
  # Depdendent on ancestry gem
  def descendant_master_files
    master_files = []
    children = Component.where(parent_component_id: id).select(:id) # Get the ids of all children of self.  Any other piece of info is extraneous.
    master_files << MasterFile.where(component_id: id) # add self.master_files
    until children.empty?
      master_files << MasterFile.where(component_id: children.map(&:id))
      children = Component.where(parent_component_id: children.map(&:id)).select(:id)
    end

    master_files.flatten
  end

  # Within the scope of a current component's parent, return the sibling component
  # objects.  Used to create links and relationships between objects.
  def sorted_siblings
    parent.children.sort_by(&:id)
  end

  def new_next
    return Component.find(followed_by_id) unless followed_by_id.nil?
  end

  def new_previous
    Component.where(followed_by_id: id).first
  end

  def next
    if parent
      @sorted_siblings = sorted_siblings
      if @sorted_siblings.find_index(self) < @sorted_siblings.length
        return @sorted_siblings[@sorted_siblings.find_index(self) + 1]
      else
        return nil
      end
    else
      return nil
    end
  end

  def previous
    if parent
      @sorted_siblings = sorted_siblings
      if @sorted_siblings.find_index(self) > 0
        return @sorted_siblings[@sorted_siblings.find_index(self) - 1]
      else
        return nil
      end
    else
      return nil
    end
  end

  def in_dl?
    self.date_dl_ingest?
  end

  # temporary method: use until db migration adds relationship
  def index_destination
    identifier = index_destination_id
    if identifier
      return IndexDestination.find(identifier)
    else
      return nil
    end
  end

  # hashes for serializing hierarchies
  # TO DO: improve sorting; The assumption here
  # is that the ordering in iView Catalog, reflected
  # here in filename numbers, will produce a good sort.
  # If for any reason MFs do not have page order reflected
  # in filenames, a :followed_by_id will need to be
  # added to this model.  See Component class for e.g.
  def master_files_pids
    master_files.sort_by(&:filename).map(&:pid)
  end
  # builds a hash for JSON publication
  # values can be either arrays of MasterFiles
  # or a hash of child components
  def descendants_hash
    hash = {};  values = []
    if children != []
      children.each do |child|
        values << child.descendants_hash
      end
    elsif master_files.count > 0
      values << master_files_pids
    end
    hash[pid] = values
    hash
  end

  # utility for export iView Catalog
  def iview_data_str
    "level=#{format_component_strings(level)} ~ pid=#{pid} ~ date=#{format_component_strings(date)} ~ desc=#{format_component_strings(iview_description)}"
  end

  alias_method :parent_component, :parent
end
