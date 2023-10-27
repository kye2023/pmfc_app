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
  
  def batch_coverage
    dc_prm = 0
    coverages.each do |cvg|
      cvg.member.dependents.each do |dpndnt|
        dpndnt.dependent_coverage.premium
        dc_prm += dpndnt.dependent_coverage.premium
      end
    end
    return dc_prm
  end

end
