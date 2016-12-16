class Qad 
	def data_request(url)
		uri = URI(url)
		Net::HTTP.get(uri)
	end

	def self.add_color_class(date)
		return_value = ""

    	if Date.strptime(date, "%m/%d/%Y") <= Time.now.to_date
			return_value = "panel-danger"
		else
			return_value = "panel-info"
		end

		return_value
	end
	
end
