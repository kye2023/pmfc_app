class Coverage < ApplicationRecord
  validates_presence_of :loan_certificate, :effectivity, :expiry, :loan_coverage, :term
  belongs_to :member
  belongs_to :batch

  def compute_age
    self.age = effectivity.year-member.birth_date.year
    # if member.present? && effectivity.present?
    # end
    primary_rate = 18..65
    case age 
    when 18..65 
      self.rate = 0.83
    when 66..70
      self.rate = 3
    when 71..75 
      self.rate = 4
    when 76..80
      self.rate = 5
    end
    #GET EXPIRY BASED ON EFFECTIVITY AND TERM
    self.expiry = effectivity >> term

    self.lppi_gross_premium = (loan_coverage/1000) * (rate * term)
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


end
