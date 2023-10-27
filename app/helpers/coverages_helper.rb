module CoveragesHelper

  # def compute_cvg_member_age(bday)
  #   today = Date.today
  #   cm_age = ((today - bday.to_date) / 365).round
  # end

  def service_fee(p)
    sfee = 0 
    case p 
    when "0"
      sfee = 0  
    when "1865" 
      sfee = 0.1
    when "6670"
      # self.rate = 3
      # self.rate = 4 if loan_coverage > 350000
    when "7175" 
      # self.rate = 4
      # self.rate = 5 if loan_coverage > 350000
    when "7680"
      # self.rate = 5
      # self.rate = 8.75 if loan_coverage > 350000
    end
    return sfee
  end

  def get_cloanpremium(age,loancoverage,term,request)

      # SET PREMIUM RATE ACCORDING TO AGE group/range
      rate = 0
      loan_premium = 0
      case age 
      when 18..65 
        rate = 0.83
      when 66..70
        rate = 3
        rate = 4 if loancoverage > 350000
      when 71..75 
        rate = 4
        rate = 5 if loancoverage > 350000
      when 76..80
        rate = 5
        rate = 8.75 if loancoverage > 350000
      end

      loan_premium = ((loancoverage/1000) * (rate * term))
      return loan_premium
  end
  
  def get_cresidency(efdate,exdate)
    # residency = (efdate.year * 12 + efdate.month) - (member.date_membership.year * 12 + member.date_membership.month)
    # return residency
  end


end
