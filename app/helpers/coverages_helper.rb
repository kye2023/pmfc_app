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

end
