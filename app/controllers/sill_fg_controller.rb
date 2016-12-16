class SillFgController < ApplicationController
	def index
		begin
			@data_group = Hash.new
			@accounted_items = Hash.new
			@completed = Array.new
			@past_due_dates = Array.new
			@current_due_dates = Array.new
			@users = Array.new
			@qad_connection = Qad.new
			qad_data_url =  "http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapisccutlist.p"
			qad_user_url =  "http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapiqaduserid.p?role=_SillFG"

			
			qad_data_json = JSON.parse(@qad_connection.data_request(qad_data_url))
			qad_user_json = JSON.parse(@qad_connection.data_request(qad_user_url))

			
			qad_user_json["users"].each do |user|
				@users << user["tt_userid"]
			end

			qad_data_json["cutlist"].each do |data|

				formatted_date = DateTime.parse(data["tt_due"]).strftime("%m/%d/%Y")
				if data["tt_completed"] == true
					data["tt_due"] = formatted_date
					@completed << data
				else
					#Add Data to Key Value Pair for grouping on the screen
					if @data_group.keys.include?(formatted_date)
						data["tt_due"] = formatted_date

						if @accounted_items.keys.include?(data["tt_Itemnumber"])
							unless @accounted_items[data["tt_Itemnumber"]].include?(formatted_date)
								@accounted_items[data["tt_Itemnumber"]] << formatted_date
								@data_group[formatted_date] << data
                            end
                        else 
                        	@accounted_items[data["tt_Itemnumber"]] = [formatted_date]
                            @data_group[formatted_date] << data
                        end
                    else
                    	data["tt_due"] = formatted_date
                    	@accounted_items[data["tt_Itemnumber"]] = [formatted_date]
                    	@data_group[formatted_date] = Array.new
                    	@data_group[formatted_date] << data
                    end

				end
			end

			@data_group.keys.each do |date|
				if Date.strptime(date, "%m/%d/%Y") <= Time.now.to_date
				  @past_due_dates << date
				else
				  @current_due_dates << date
				end
			end
			@users.sort!
		rescue Exception => error
			p "Error #{error}"
		end
	end

	def inv_update_from_qad
		selected_item = params[:selected_item]
		@qad_connection = Qad.new
		response = JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapipartinv.p?Part=" + selected_item))
		
		respond_to do |format|
		  format.json { render json: response["inv"] }
		end
	end		

	def sales_order_from_qad
		selected_item = params[:selected_item]
		due_date = Formatter.date(params[:due_date])

		@qad_connection = Qad.new
		response = JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapisccutlist.p?due=" + due_date + "&parent=all&comp=" + selected_item))
		
		respond_to do |format|
		  format.json { render json: response["cutlist"] }
		end
	end

	def submit_trans
		item_num = params[:item_num]
		from_loc = params[:from_loc]
		to_loc = params[:to_loc]
		tag = params[:tag]
		qty_to_move = params[:qty_to_move]
		user_id = params[:user_id]
		type = params[:type]
		@qad_connection = Qad.new
		
		response = JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapipul.p?item=" + item_num + "&qty=" + qty_to_move + "&floc=" + from_loc + "&fref=" + tag + "&tloc=" + to_loc + "&fsite=2000&tsite=2000&user=" + user_id + "&type=" + type ))
		
		respond_to do |format|
		  format.json { render json: response }
		end
	end

	def change_status
		order_num = params[:order_num]
		line_num = params[:line_num]
		status = params[:status]
		@qad_connection = Qad.new
		
		JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapiscfgclcomplete.p?order=" + order_num + "&line=" + line_num + "&status=" + status))
		
		get_completed_data_only
	end

	# def updateSingleDateDom(date)
	# 	@qad_connection = Qad.new
	# 	p JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapisccutlist.p?complete=n"))
	# end
 
 	def multi_complete
 		item_num = params[:item_num]
 		due_date = Formatter.date(params[:due_date])
 		@qad_connection = Qad.new
 		response = JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapisccutlist.p?due=" + due_date + "&comp=" + item_num))
 		begin
 			response["cutlist"].each do |json_data|
 				@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapiscfgclcomplete.p?order=" + json_data["tt_salesorder"] + "&line=" + json_data["tt_line"].to_s + "&status=y")
 			end
 			respond_to do |format|
 				format.json {render json: response["cutlist"].count }
 			end
 		rescue Exception => error
 			p "Error caught #{error}"
 		end
 	end


 	def get_date_specific_data
 		due_date = Formatter.date(params[:due_date])
 		@qad_connection = Qad.new
 		
 		response = JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapisccutlist.p?due=" + due_date + "&complete=n"))

 		respond_to do |format|
 		  format.json {render json: response["cutlist"]}
 		end
 	end

 	def check_for_add_ons
 		date = params[:request_time]
 		qad_connection = Qad.new
 		response = JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapiaddon.p?start=" + date))
 		response["AddOns"].count
 	end

 	def get_completed_data_only
		@qad_connection = Qad.new
		response = JSON.parse(@qad_connection.data_request("http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/xxapisccutlist.p?complete=y"))
		respond_to do |format|
			format.json {render json: response}
		end
 	end

end
