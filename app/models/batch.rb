class Batch < ApplicationRecord
  has_one :premium_rate
  has_many :coverages
  has_many :members, through: :coverages
  has_many :dependent_coverages
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

  def self.to_csv 
    CSV.generate(col_sep: ";") do |csv|
      csv << ["id", "coop","last_name", "first_name", "middle_name", "birth_date", "mobile_no", "email", "guest_type", "attend", "price", "paid", "award", "size", "tentative", "dietary", "registered"]
      all.find_each do |reg|
        csv << [reg.id, reg.event_hub.cooperative.name, reg.last_name, reg.first_name, reg.middle_name, reg.birth_date, reg.mobile_number, reg.email, reg.guest_type, reg.attend, reg.price, reg.paid, reg.award, reg.size, reg.tentative, reg.dietary, reg.created_at]
      end
    end
  end

end
