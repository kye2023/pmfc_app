class Coverage < ApplicationRecord
  validates_presence_of :loan_certificate, :effectivity, :expiry, :loan_coverage, :term
  belongs_to :member
  belongs_to :batch
  belongs_to :group_benefit

  def compute_age
    self.age = effectivity.year-member.birth_date.year
    # if member.present? && effectivity.present?
    # end
    # primary_rate = 18..65
    case age 
    when 18..65 
      self.rate = 0.83
    when 66..70
      self.rate = 3
      self.rate = 4 if loan_coverage > 350000
    when 71..75 
      self.rate = 4
      self.rate = 5 if loan_coverage > 350000
    when 76..80
      self.rate = 5
      self.rate = 8.75 if loan_coverage > 350000
    end
    
    #GET EXPIRY BASED ON EFFECTIVITY AND TERM
    self.expiry = effectivity >> term

    self.loan_premium = (loan_coverage/1000) * (rate * term)
    self.residency = (effectivity.year * 12 + effectivity.month) - (member.date_membership.year * 12 + member.date_membership.month)

    

    #search group premium
    gp = GroupPremium.where('? between residency_floor and residency_ceiling', self.residency)
    self.group_premium = gp.find_by(member_type: 'principal', term: self.term).premium unless gp.nil?
    #search group benefit
    gb = GroupBenefit.where('? between residency_floor and residency_ceiling', self.residency)
    self.group_benefit_id = gp.find_by(member_type: 'principal').id

    self.member.dependents.each do |dependent|
      dep_coverage = DependentCoverage.new 
      
    end

  end
  
  def coverage_aging
    #today = Date.today
    #c_aging = ((exdate.to_date - efdate.to_date) / 31).round
    #self.term = c_aging

    if expiry.present? && effectivity.present?
      ((expiry.to_date - effectivity.to_date) / 31).round
    end
    
  end

  def coverage_date
    cv_efdate = effectivity.strftime("%m/%d/%Y") 
    cv_exdate = expiry.strftime("%m/%d/%Y")
    "#{cv_efdate}"+ " - " + "#{cv_exdate}"
  end

  def coverage_status
    vstatus = ""
    if status == "N"
      vstatus = "New"
    else
      vstatus = "Renewal"
    end
  end

  def coverage_lppi_premium
    # lppi_prem = batch.premium_rate.premium
    # if lppi_gross_coverage.present? && term.present?
    #   ((lppi_gross_coverage / 1000) * (term * lppi_prem))
    # end
  end

  def get_group_life
    #return coverage.group_benefits.life
  end

  def alpharray(val)
    numalpha = Array["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    return numalpha[val-1]
  end


end
