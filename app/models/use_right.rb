class UseRight < ActiveRecord::Base
  has_many :bibls
  has_many :components
  has_many :master_files
  has_many :units

  validates :description, :name, presence: true
  validates :name, uniqueness: true
end
