class Batch < ApplicationRecord
  has_one :premium_rate
  has_many :coverages
  has_many :members, through: :coverages
  has_many :dependent_coverages
  belongs_to :branch
  validates_presence_of :title
  require 'csv'
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
        if dpndnt.dependent_coverage.nil?
          dc_prm  
        else
          dc_prm += dpndnt.dependent_coverage.premium
        end
      end
    end
    return dc_prm
  end

  def batch_csv(batch_id) 
    @batch = Batch.find(batch_id)
    # raise "errors"
    CSV.generate(col_sep: ";") do |csv|
      csv << ["id","member_typ", "first_name", "middle_name", "last_name", "suffix", "certificate", "residency", "effectiity", "expiry", "terms", "grace_period", "status", "loan_coverage", "loan_premium", "life", "ad&d", "burial", "group_premium"]
      @batch.coverages.each do |cov|
        csv << [cov.id, "principal", cov.member.first_name, cov.member.middle_name, cov.member.last_name, cov.member.suffix, cov.loan_certificate, cov.residency, cov.effectivity, cov.expiry, cov.term, cov.grace_period, cov.status, cov.loan_coverage, cov.loan_premium, cov.group_benefit.life, cov.group_benefit.add, cov.group_benefit.burial, cov.group_premium]
        cov.dependent_coverages.each do |dep|
          csv << [dep.id, "dependent", dep.dependent.first_name, dep.dependent.middle_name, dep.dependent.last_name, dep.dependent.suffix, dep.dependent.relationship, cov.residency, cov.effectivity, cov.expiry, cov.term, cov.grace_period, cov.status, 0, 0, dep.group_benefit.life, dep.group_benefit.add, dep.group_benefit.burial, dep.premium]
        end
      end
    end
  end

end
