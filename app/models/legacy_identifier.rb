class LegacyIdentifier < ActiveRecord::Base
  has_and_belongs_to_many :bibls
  has_and_belongs_to_many :components
  has_and_belongs_to_many :master_files
  has_and_belongs_to_many :units

  def destroyable?
    if master_files.empty? && components.empty? && bibls.empty?
      return true
    else
      return false
    end
  end
end
