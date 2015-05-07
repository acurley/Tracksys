class AvailabilityPolicy < ActiveRecord::Base

  has_many :bibls
  has_many :components
  has_many :master_files
  has_many :units

  validates :name, :xacml_policy_url, :presence => true, :uniqueness => true
  validates :xacml_policy_url, :format => {:with => URI::regexp(['http','https'])}

  def xacml_policy_url
    return "#{self.repository_url}/fedora/objects/#{self.pid}/datastreams/XACML/content"
  end
end
