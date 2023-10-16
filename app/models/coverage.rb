class Coverage < ApplicationRecord
  validates_presence_of :loan_certificate, :effectivity, :expiry, :status, :lppi_gross_coverage
  belongs_to :member
  belongs_to :batch

  def compute_age
    #today = Date.today
    #c_age = ((edate.to_date - bday.to_date) / 365).round
    #self.age = c_age

    if member.present? && effectivity.present?
      return effectivity.year-member.birth_date.year
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
    if lppi_gross_coverage.present? && term.present?
      
      lppi_prem = batch.premium_rate.premium
      ((lppi_gross_coverage / 1000) * (term * lppi_prem))

    end
  end


end
