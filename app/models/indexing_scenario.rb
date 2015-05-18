class IndexingScenario < ActiveRecord::Base
  default_scope order: :name

  has_many :bibls
  has_many :components
  has_many :master_files
  has_many :units

  validates :name, :pid, :repository_url, :datastream_name, presence: true
  validates :name, :pid, uniqueness: true
  validates :repository_url, format: { with: URI.regexp(%w(http https)) }

  def complete_url
    "#{repository_url}/fedora/objects/#{pid}/datastreams/#{datastream_name}/content"
  end
end
