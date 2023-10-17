module ApplicationHelper

    def to_curr(amount)
		number_to_currency(amount, unit: "")
	end

	def to_shortdate(date)
		date.strftime('%b %d, %Y')
	end
end
