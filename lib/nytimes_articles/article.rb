module Nytimes
	module Articles
		class Article < Base
			QUERY_FIELDS = %w(abstract author body byline fee lead_paragraph multimedia nytd_lead_paragraph nytd_title related_multimedia small_image small_image_url small_image_height small_image_width title url word_count)
			
			ALL_FIELDS = QUERY_FIELDS + Facet::ALL_FACETS
			
			attr_reader *QUERY_FIELDS
			attr_reader *(Facet::ALL_FACETS.map {|f| f.gsub('_facet', '')})
			
			def initialize(params={})
				params.each_pair do |k,v|
					instance_variable_set("@#{k}", v)
				end
			end
			
			def self.date_argument(field_name, arg)
				return arg if arg.is_a? String
				return arg.strftime("%Y%m%d") if arg.respond_to? :strftime
				raise ArgumentError, "Only a string or Date/Time object is allowed as a parameter to the #{field_name} input"
			end
			
			def self.facet_params(params, facet_name)
				return nil if params[facet_name].nil?
				
				params[facet_name].map {|f| Facet.new(facet_name, f, nil) }
			end
			
			def self.integer_field(value)
				return nil if value.nil?
				value.to_i
			end
			
			def self.date_field(value)
				return nil unless value =~ /^\d{8}$/
				Date.strptime(value, "%Y%m%d")
			end
			
			def self.init_from_api(params)
				Article.new(
					:abstract => params['abstract'],
					:author => params['author'],
					:body => params['body'],
					:byline => params['byline'],
					:fee => params['fee'] || false,
					:lead_paragraph => params['lead_paragraph'],
					:nytd_title => params['nytd_title'],
					:related_multimedia => nil, # FIXME
					:image => nil, # FIXME
					:title => params['title'],
					:url => params['url'],
					:word_count => params['word_count'],
					
					# FACETS THAT RETURN SCALARS
					:page => params[Facet::PAGE],
					:column => params[Facet::COLUMN],
					:pub_month => integer_field(params[Facet::PUB_MONTH]),
					:pub_year => integer_field(params[Facet::PUB_YEAR]),
					:pub_day => integer_field(params[Facet::PUB_DAY]),
					:day_of_week => params[Facet::DAY_OF_WEEK],
					:desk => params[Facet::DESK],
					:date => date_field(params[Facet::DATE]),
					:section_page => params[Facet::SECTION_PAGE],
					:source => params[Facet::SOURCE],
					
					# FACETS THAT RETURN ARRAYS
					:classifiers => facet_params(params, Facet::CLASSIFIERS),
					:geographic => facet_params(params, Facet::GEOGRAPHIC)
				)
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
				
				if params[:query]
					api_params['query'] = params[:query]
				end
				
				if params[:rank]
					unless [:newest, :oldest, :closest].include?(params[:rank])
						raise ArgumentError, "Rank should only be :newest | :oldest | :closest"
					end
					
					api_params['rank'] = params[:rank].to_s
				end
				
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