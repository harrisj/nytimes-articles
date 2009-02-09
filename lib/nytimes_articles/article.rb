module Nytimes
	module Articles
		class Article < Base
			attr_reader :abstract, :author, :byline, :body
			
			def self.date_argument(field_name, arg)
				return arg if arg.is_a? String
				return arg.strftime("%Y%m%d") if arg.respond_to? :strftime
				raise ArgumentError, "Only a string or Date/Time object is allowed as a parameter to the #{field_name} input"
			end
			
			def self.search(query, params={})
				params = params.dup
				
				case query
				when String
					params[:query] = query
				when Hash
					params.merge! query
				end
				
				api_params = {}
				
				if params[:begin_date]
					api_params['begin_date'] = date_argument(:begin_date, params[:begin_date])
				end
				
				if params[:end_date]
					api_params['end_date'] = date_argument(:end_date, params[:end_date])
				end
				
				if params[:page]
					unless params[:page].is_a? Integer
						raise ArgumentError, "Page must be an integer"
					end
					
					# Page counts from 1, offset counts from 0
					api_params['offset'] = params[:page] - 1
				end
				
				if params[:offset]
					unless params[:offset].is_a? Integer
						raise ArgumentError, "Offset must be an integer"
					end
					
					api_params['offset'] = params[:offset]
				end
				
				invoke(api_params)
			end
		end
	end
end