class Coverage < ApplicationRecord
  validates_presence_of :member_id, :loan_certificate, :effectivity, :term, :grace_period, :status, :loan_coverage
  belongs_to :member, optional: true
  belongs_to :batch
  belongs_to :group_benefit, optional: true
  has_many :dependent_coverages, dependent: :destroy

  TERMS = [3, 4, 5, 6, 9, 12, 18, 24, 30]

  def compute_age
    
    #binding.pry
    
    self.age = effectivity.year-member.birth_date.year
    # SET PREMIUM RATE ACCORDING TO AGE group/range
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
    self.expiry = expiry + grace_period

    self.loan_premium = (loan_coverage/1000) * (rate * (term + grace_period))
    self.residency = (effectivity.year * 12 + effectivity.month) - (member.date_membership.year * 12 + member.date_membership.month)

    gp = GroupPremium.where('? between residency_floor and residency_ceiling', self.residency)
    self.group_premium = gp.find_by(member_type: 'principal', term: self.term).premium unless gp.nil?

    gb = GroupBenefit.where('? between residency_floor and residency_ceiling', self.residency)
    self.group_benefit_id = gb.find_by(member_type: 'principal').id

    #SEARCH GROUP BENEFIT
    # g_bnft = GroupBenefit.where('? between residency_floor and residency_ceiling', self.residency)
    # self.group_benefit_id = g_bnft.find_by(member_type: 'principal').id
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

  # def alpharray(val)
  #   numalpha = Array["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
  #   return numalpha[val-1]
  # end


end
