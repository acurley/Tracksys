require "#{Hydraulics.models_dir}/bibl"

class Bibl

  include Pidable
  has_and_belongs_to_many :teis

  VIRGO_FIELDS = ['title', 'creator_name', 'creator_name_type', 'call_number', 'catalog_key', 'barcode', 'copy', 'date_external_update', 'location', 'citation', 'year', 'year_type', 'location', 'copy', 'title_control', 'date_external_update']

  #------------------------------------------------------------------
  # aliases
  #------------------------------------------------------------------
  # Necessary for Active Admin to poplulate pulldown menu
  alias_attribute :name, :title

  def physical_virgo_url
    return "#{VIRGO_URL}/#{self.catalog_key}"
  end

  def dl_virgo_url
    return "#{VIRGO_URL}/#{self.pid}"
  end

  def fedora_url
    return "#{FEDORA_REST_URL}/objects/#{self.pid}"
  end
end
