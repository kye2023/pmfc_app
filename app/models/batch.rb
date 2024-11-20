class Batch < ApplicationRecord
  has_one :premium_rate
  has_many :coverages, dependent: :destroy
  has_many :members, through: :coverages
  has_many :dependent_coverages, dependent: :destroy
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
      dc_prm += cvg.dependent_coverages.sum(:premium)
    end
    return dc_prm
  end

  #--------------------------------------------------------------------------------------------------------------------------

  def bcount_mbr(plan)
    c_imbr = 0
    c_gmbr = 0

    case plan
    when "0"
      coverages.each do |cvg|
        if cvg.member.plan_lppi == true
          c_imbr += 1
        end
      end
      return c_imbr
    when "1"
      coverages.each do |cvg|
        if cvg.member.plan_sgyrt == true
          c_gmbr += 1
        end
      end
      return c_gmbr
    end
  end

  def sum_insured_mbr(plan)
    s_imbr = 0
    s_gmbr = 0

    case plan
    when "0"
      coverages.each do |cvg|
        if cvg.member.plan_lppi == true
          s_imbr += cvg.loan_coverage
        end
      end
      return s_imbr
    when "1"
      plife = 0
      dlife = 0
      tlife = 0
      coverages.each do |cvg|
        if cvg.member.plan_sgyrt == true
          plife += cvg.group_benefit.life
          cvg.dependent_coverages.each do |dp|  
            dlife += dp.group_benefit.life
          end
        end
      end
      s_gmbr = plife + dlife
      return s_gmbr
    end
  end

  def batch_cvg_pprm
    pc_prm = 0
    coverages.each do |cvg|
      if cvg.member.plan_sgyrt == true
        pc_prm += cvg.group_premium
      end
    end
    return pc_prm
  end

  def batch_cvg_dprm
    dc_prm = 0
    coverages.each do |cvg|
      dc_prm += cvg.dependent_coverages.sum(:premium)
    end
    return dc_prm
  end

  #--------------------------------------------------------------------------------------------------------------------------

  def self.get_batches_index(admin, query, current_user)
    if query.present?
      if admin == true
        where("title LIKE ?", "%#{query}%")
      else
        where("title LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%").where(branch_id: current_user.user_detail.branch_id)
      end
    else
      if admin == true
        limit(100).all
      else
        where(branch_id: current_user.user_detail.branch_id).limit(100)
      end
    end
  end

  def batch_csv(batch_id) 
    @batch = Batch.find(batch_id)
    CSV.generate(col_sep: ";") do |csv|
      csv << ["id","member_typ", "first_name", "middle_name", "last_name", "suffix", "certificate", "residency", "effectiity", "expiry", "terms", "grace_period", "status", "loan_coverage", "loan_premium", "life", "ad&d", "burial", "group_premium"]
      @batch.coverages.each do |cov|
        csv << [
          cov.id, 
          "principal", 
          cov.member.first_name, 
          cov.member.middle_name, 
          cov.member.last_name, 
          cov.member.suffix, 
          cov.loan_certificate, 
          cov.residency, 
          cov.effectivity, 
          cov.expiry, 
          cov.term, 
          cov.grace_period, 
          cov.status, 
          cov.loan_coverage, 
          cov.loan_premium, 
          cov.group_benefit.life, 
          cov.group_benefit.add, 
          cov.group_benefit.burial, 
          cov.group_premium
        ]
        cov.dependent_coverages.each do |dep|
          csv << [
            dep.id, 
            "dependent", 
            dep.dependent.first_name, 
            dep.dependent.middle_name, 
            dep.dependent.last_name, 
            dep.dependent.suffix, 
            dep.dependent.relationship, 
            cov.residency, 
            cov.effectivity, 
            cov.expiry, 
            cov.term, 
            cov.grace_period, 
            cov.status, 
            0, 
            0, 
            dep.group_benefit.life, 
            dep.group_benefit.add, 
            dep.group_benefit.burial, 
            dep.premium
          ]
        end
      end
    end
  end



end
