require 'rubygems'

module Nytimes
	module Articles
		class Article < Base
			RAW_FIELDS = %w(url)
			TEXT_FIELDS = %w(abstract author body byline lead_paragraph nytd_lead_paragraph nytd_title title)
			NUMERIC_FIELDS = %w(word_count)
			BOOLEAN_FIELDS = %w(fee small_image)
			IMAGE_FIELDS = %w(small_image small_image_url small_image_height small_image_width)
			MULTIMEDIA_FIELDS = %w(multimedia related_multimedia)
			
			ALL_FIELDS = TEXT_FIELDS + RAW_FIELDS + NUMERIC_FIELDS + BOOLEAN_FIELDS + IMAGE_FIELDS + MULTIMEDIA_FIELDS + Facet::ALL_FACETS
			
			attr_reader *ALL_FIELDS
			attr_reader *(Facet::ALL_FACETS.map {|f| f.gsub('_facet', '')})
			
			##
			# Create a new Article from hash arguments. You really don't need to call this as Article instances are automatically returned from the API
			def initialize(params={})
				params.each_pair do |k,v|
					instance_variable_set("@#{k}", v)
				end
			end
			
			alias :fee? :fee
			def free?
				not(fee?)
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
			
			def self.text_argument(field, argument)
				arg = argument.dup
				subquery = []
				while term = arg.slice!(%r{("[^"]+")|\S+})
					if term =~ /^\-/
						subquery << "-#{field}:#{term[1..term.length]}"
					else
						subquery << "#{field}:#{term}"
					end
				end
				
				subquery.join(' ')
			end
			
			def self.init_from_api(params)
				article = Article.new(
					:abstract => text_field(params['abstract']),
					:author => text_field(params['author']),
					:body => text_field(params['body']),
					:byline => text_field(params['byline']),
					:fee => params['fee'] || false,
					:lead_paragraph => text_field(params['lead_paragraph']),
					:nytd_title => text_field(params['nytd_title']),
					:nytd_lead_paragraph => text_field(params['nytd_lead_paragraph']),
					:related_multimedia => nil, # FIXME
					:image => nil, # FIXME
					:title => text_field(params['title']),
					:url => params['url'],
					:word_count => integer_field(params['word_count']),
					
					# FACETS THAT RETURN SCALARS
					:page => integer_field(params[Facet::PAGE]),
					:column => text_field(params[Facet::COLUMN]),
					:pub_month => integer_field(params[Facet::PUB_MONTH]),
					:pub_year => integer_field(params[Facet::PUB_YEAR]),
					:pub_day => integer_field(params[Facet::PUB_DAY]),
					:day_of_week => params[Facet::DAY_OF_WEEK],
					:desk => text_field(params[Facet::DESK]),
					:date => date_field(params[Facet::DATE]),
					:section_page => params[Facet::SECTION_PAGE],
					:source => text_field(params[Facet::SOURCE]),
					
					# FIXME! MORE FACET PARAMS
					# FACETS THAT RETURN ARRAYS
					:classifiers => facet_params(params, Facet::CLASSIFIERS),
					:geographic => facet_params(params, Facet::GEOGRAPHIC)
				)
				
				article
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
				
				add_query_params(api_params, params)
				add_fields_param(api_params, params)
				add_facets_param(api_params, params)
				add_rank_params(api_params, params)
				add_date_params(api_params, params)
				add_offset_params(api_params, params)
								
				reply = invoke(api_params)
				parse_reply(reply)
			end
			
private
			def self.parse_reply(reply)
				ResultSet.init_from_api(reply)
			end
			
			def self.add_facets_param(out_params, in_params)
				if in_params[:facets]
					out_params['facets'] = in_params[:facets].to_a.join(',')
				end
			end
			
			def self.add_fields_param(out_params, in_params)
				case in_params[:fields]
				when nil
					# do nothing
				when :all
					out_params['fields'] = ALL_FIELDS.join(',')
				when String, Symbol
					out_params['fields'] = in_params[:fields].to_s
				when Array
					out_params['fields'] = in_params[:fields].map {|f| f.to_s}.join(',')
				else
					raise ArgumentError, "Fields must either be :all, a single field name, or an array of field names (either strings or symbols)"
				end	
			end
			
			def self.add_query_params(out_params, in_params)
				query = []
					
				query << in_params[:query]
				
				# Also add other text params to the query
				TEXT_FIELDS.each do |tf|
					if in_params[tf.to_sym]
						query << text_argument(tf, in_params[tf.to_sym])
					end
				end
					
				out_params['query'] = query.compact.join(' ')
			end
			
			def self.add_rank_params(out_params, in_params)
				if in_params[:rank]
					unless [:newest, :oldest, :closest].include?(in_params[:rank])
						raise ArgumentError, "Rank should only be :newest | :oldest | :closest"
					end
					
					out_params['rank'] = in_params[:rank].to_s
				end
			end
			
			def self.add_date_params(out_params, in_params)
				if in_params[:begin_date]
					out_params['begin_date'] = date_argument(:begin_date, in_params[:begin_date])
				end
				
				if in_params[:end_date]
					out_params['end_date'] = date_argument(:end_date, in_params[:end_date])
				end
			end
			
			def self.add_offset_params(out_params, in_params)
				if in_params[:page]
					unless in_params[:page].is_a? Integer
						raise ArgumentError, "Page must be an integer"
					end
					
					unless in_params[:page] >= 1
						raise ArgumentError, "Page must count up from 1"
					end
					
					# Page counts from 1, offset counts from 0
					out_params['offset'] = in_params[:page] - 1
				end
				
				if in_params[:offset]
					unless in_params[:offset].is_a? Integer
						raise ArgumentError, "Offset must be an integer"
					end
					
					out_params['offset'] = in_params[:offset]
				end
			end
			
		end
	end
end