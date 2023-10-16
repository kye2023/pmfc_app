class PremiumRate < ApplicationRecord
  validates_presence_of :premium
  belongs_to :batch
  #belongs_to :coverage

  def prm_category
    cat = "#{min_age}" + " - " + "#{max_age}" + " y/o"
  end
end
