module ApplicationHelper
  include Pagy::Frontend

# Pagy::DEFAULT[:items] = 15
# Pagy::DEFAULT[:size]  = [1,4,4,1] 

  def to_curr(amount)
		number_to_currency(amount, unit: "")
	end

	def to_numdelimit(numbr)
		number_with_precision(numbr, :precision => 0, :delimiter => ',')	
	end

	def to_shortdate(date)
		date.strftime('%b %d, %Y')
	end
end
