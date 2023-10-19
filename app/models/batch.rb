class Batch < ApplicationRecord
  has_one :premium_rate
  has_many :coverages
  has_many :members, through: :coverages
  belongs_to :branch
  validates_presence_of :title

  def batch_info
    "#{description}" + " ("+ "#{title}" + ")"
  end

  def batch_premium
   return premium_rate.premium 
  end
end
