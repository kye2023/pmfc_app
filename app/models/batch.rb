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
      if cvg.plan_sgyrt? == true
        dc_prm += cvg.dependent_coverages.sum(:premium)
      end
    end
    return dc_prm
  end

  #--------------------------------------------------------------------------------------------------------------------------

  def bcount_mbr(arr, plan)
    c_imbr = 0
    c_gmbr = 0

    case plan
    when "0"
      arr.each do |acvg|
        if acvg.member.plan_lppi == true
          c_imbr += 1
        end
      end
      return c_imbr
    when "1"
      arr.each do |acvg|
        if acvg.member.plan_sgyrt == true
          c_gmbr += 1
        end
      end
      return c_gmbr
    end
  end

  def sum_insured_mbr(arr, plan)
    s_imbr = 0
    s_gmbr = 0

    case plan
    when "0"
      arr.each do |ascvg|
        if ascvg.member.plan_lppi == true
          s_imbr += ascvg.loan_coverage
        end
      end
      return s_imbr
    when "1"
      plife = 0
      dlife = 0
      tlife = 0
      arr.each do |ascvg|
        if ascvg.member.plan_sgyrt == true
          plife += ascvg.group_benefit.life
          ascvg.dependent_coverages.each do |dp|  
            dlife += dp.group_benefit.life
          end
        end
      end
      s_gmbr = plife + dlife
      return s_gmbr
    end
  end

  def batch_cvg_pprm(arr)
    pc_prm = 0
    arr.each do |bcvg|
      if bcvg.member.plan_sgyrt == true
        pc_prm += bcvg.group_premium
      end
    end
    return pc_prm
  end

  def batch_cvg_dprm(arr)
    dc_prm = 0
    arr.each do |dcvg|
      dc_prm += dcvg.dependent_coverages.sum(:premium)
    end
    return dc_prm
  end

  #--------------------------------------------------------------------------------------------------------------------------

  def self.get_batches_index(admin, query, current_user)
    if query.present? 
      # search/text_field/query has value
      if admin == true
        where("title LIKE ?", "%#{query}%")
      else
        where("title LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%").where(branch_id: current_user.user_detail.branch_id)
      end
    else 
      # search/text_field/query is empty
      if admin == true
        limit(100).all
      else
        where(branch_id: current_user.user_detail.branch_id).limit(100)
      end

    end
  end

  def self.get_batches_query(bId, query, current_user, age_group)
    
    if query.present? == true
      # raise "errors"
      mbr = Member.where("last_name LIKE ? OR first_name LIKE ?", "%#{query}%", "%#{query}%")
      case age_group
      when "1865"
        bId.coverages.where(age: 18..65)
      when "6670b"
        bId.coverages.where(age: 66..70).where("loan_coverage <= 350000")
      when "6670a"
        bId.coverages.where(age: 66..70).where("loan_coverage > 350001")
      when "7175b"
        bId.coverages.where(age: 71..75).where("loan_coverage <= 350000")
      when "7175a"
        bId.coverages.where(age: 71..75).where("loan_coverage > 350001")
      when "7680b"
        bId.coverages.where(age: 76..80).where("loan_coverage <= 350000")
      when "7680a"
        bId.coverages.where(age: 76..80).where("loan_coverage > 350001")
      when "0119"
        bId.coverages.where("residency BETWEEN 0 AND 119")
      when "120a"
        bId.coverages.where("residency > 120").where(member_id: mbr.pluck(:id))
      else
        bId.coverages.where(member_id: mbr.pluck(:id))
      end

    else
      case age_group
      when "1865"
        bId.coverages.where(age: 18..65)
      when "6670b"
        bId.coverages.where(age: 66..70).where("loan_coverage <= 350000")
      when "6670a"
        bId.coverages.where(age: 66..70).where("loan_coverage > 350001")
      when "7175b"
        bId.coverages.where(age: 71..75).where("loan_coverage <= 350000")
      when "7175a"
        bId.coverages.where(age: 71..75).where("loan_coverage > 350001")
      when "7680b"
        bId.coverages.where(age: 76..80).where("loan_coverage <= 350000")
      when "7680a"
        bId.coverages.where(age: 76..80).where("loan_coverage > 350001")
      when "0119"
        bId.coverages.where("residency BETWEEN 0 AND 119")
      when "120a"
        bId.coverages.where("residency > 120")
      else
        bId.coverages
      end
    end

  end

  def get_service_fee(prem, age_r, sfee)
    csfee = 0
    if sfee.present? == true
      case age_r
      when "1865"
        csfee = (prem * (sfee / 100)).round(2)
      when "0119"
        csfee = (prem * (sfee / 100)).round(2)
      when "120a"
        csfee = (prem * (sfee / 100)).round(2)
      else
        csfee = 0
      end
    else
      csfee = 0
    end
    return csfee
  end

  def total_net_premium(prem, age_r, sfee)
    tnprem = 0
    if sfee.present? == true 
      case age_r
        when "1865"
          tnprem = (prem - sfee)
        when "0119"
          tnprem = (prem - sfee)
        when "120a"
          tnprem = (prem - sfee)
        else
          tnprem = prem
        end
    else
      tnprem = prem
    end
    return tnprem
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
