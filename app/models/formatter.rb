class Formatter

	def self.date(date)
		begin
			due_date = DateTime.parse(date).strftime("%m/%d/%Y")
		rescue Exception => error
			due_date = Date.strptime(date, "%m/%d/%Y").strftime("%m/%d/%Y")
		end
	end
end