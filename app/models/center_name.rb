class CenterName < ApplicationRecord
  belongs_to :branch
  has_many :coverages
  validates_presence_of :description

end
