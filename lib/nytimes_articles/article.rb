require 'rubygems'

module Nytimes
	module Articles
		##
		# The Article class represents a single article returned from the New York Times Article Search API. Note that an article can have many attributes
		# but these are not necessarily populated unless you explicitly request them in the reply from the server via the <tt>:fields</tt> parameter to 
		# search (or use <tt>:fields => :all</tt>). 
		class Article < Base
			RAW_FIELDS = %w(url)
			TEXT_FIELDS = %w(abstract author body byline lead_paragraph nytd_lead_paragraph nytd_title title)
			NUMERIC_FIELDS = %w(word_count)
			BOOLEAN_FIELDS = %w(fee small_image)
			IMAGE_FIELDS = %w(small_image small_image_url small_image_height small_image_width)
			MULTIMEDIA_FIELDS = %w(multimedia related_multimedia)

			ALL_FIELDS = TEXT_FIELDS + RAW_FIELDS + NUMERIC_FIELDS + BOOLEAN_FIELDS + MULTIMEDIA_FIELDS + Facet::ALL_FACETS + IMAGE_FIELDS

			attr_reader *ALL_FIELDS
			
			# special additional objects
			attr_reader :thumbnail
			
			# Scalar facets
			attr_reader :page, :column, :pub_month, :pub_year, :pub_day, :day_of_week, :desk, :date, :section_page, :source

			# Facets that return multiple values
			attr_reader :classifiers, :descriptions, :geo, :material_types, :organizations, :persons, :nytd_bylines, :nytd_descriptions, :nytd_geo, :nytd_organizations, :nytd_persons, :nytd_sections, :nytd_works_mentioned, :works_mentioned
			alias :people :persons
			alias :nytd_people :nytd_persons
			
			##
			# Create a new Article from hash arguments. You really don't need to call this as Article instances are automatically returned from the API
			def initialize(params={})
				params.each_pair do |k,v|
					instance_variable_set("@#{k}", v)
				end
			end

			##
			# Is this article available for a fee?
			alias :fee? :fee

			##
			# Is this article available for free?
			def free?
				not(fee?)
			end

			##
			# Creates a new Article from the a hash returned from the API. This is called on search results. You have no reason to call it.
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
				:thumbnail => Thumbnail.init_from_api(params),
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
				:descriptions => facet_params(params, Facet::DESCRIPTION),
				:geo => facet_params(params, Facet::GEO),
				:material_types => facet_params(params, Facet::MATERIAL_TYPE),
				:organizations => facet_params(params, Facet::ORGANIZATION),
				:persons => facet_params(params, Facet::PERSON),
				:nytd_bylines => facet_params(params, Facet::NYTD_BYLINE),
				:nytd_descriptions => facet_params(params, Facet::NYTD_DESCRIPTION),
				:nytd_geo => facet_params(params, Facet::NYTD_GEO),
				:nytd_organizations => facet_params(params, Facet::NYTD_ORGANIZATION),
				:nytd_persons => facet_params(params, Facet::NYTD_PERSON),
				:nytd_sections => facet_params(params, Facet::NYTD_SECTION),
				:nytd_works_mentioned => facet_params(params, Facet::NYTD_WORKS_MENTIONED),
				:works_mentioned => facet_params(params, Facet::WORKS_MENTIONED)
				)

				article
			end

			##
			# Executes a search against the Article Search API and returns a ResultSet of 10 articles. At its simplest form, can be invoked
			# with just a string like so
			#
			#   Article.search 'dog food'
			# 
			# which will do a text search against several text fields in the article and return the most basic fields for each
			# article, but it takes a large number of potential parameters. All of these fields and then some can be returned as display fields
			# in the articles retrieved from search (see the <tt>:fields</tt> argument below)
			#
			# == TEXT FIELDS
			#
			# If passed a string as the first argument, the text will be used to search against the title, byline and body fields of articles. This text takes
			# the following boolean syntax:
			# * <tt>dog food</tt> - similar to doing a boolean =AND search on both terms
			# * <tt>"ice cream"</tt> - matches the words as a phrase in the text
			# * <tt>ice -cream</tt> - to search text that doesn't contain a term, prefix with the minus sign.
			#
			# Should you wish to target text against specific text fields associated with the article, the following named parameters are supported:
			# * <tt>:abstract</tt> - A summary of the article, written by Times indexers
			# * <tt>:body</tt> - A portion of the beginning of the article. Note: Only a portion of the article body is included in responses. But when you search against the body field, you search the full text of the article.
			# * <tt>:byline</tt> - The article byline, including the author's name
			# * <tt>:lead_paragraph</tt> - The first paragraph of the article (as it appeared in the printed newspaper)
			# * <tt>:nytd_byline</tt> - The article byline, formatted for NYTimes.com
			# * <tt>:nytd_lead_paragraph</tt> - The first paragraph of the article (as it appears on NYTimes.com)
			# * <tt>:nytd_title</tt> - The article title on NYTimes.com (this field may or may not match the title field; headlines may be shortened and edited for the Web) 
			# * <tt>:text</tt> - The text field consists of title + byline + body (combined in an OR search) and is the default field for keyword searches.
			# * <tt>:title</tt> - The article title (headline); corresponds to the headline that appeared in the printed newspaper
			# * <tt>:url</tt> - The URL of the article on NYTimes.com
			#
			# == FACET SEARCHING
			# 
		  # Beyond query searches, the NY Times API also allows you to search against controlled vocabulary metadata associated with the article. This is powerful, if you want precise matching against specific
		  # people, places, etc (eg, "I want stories about Ford the former president, not Ford the automative company"). The following Facet constants are supported.
		  #
			# * <tt>Facet::CLASSIFIERS</tt> - Taxonomic classifiers that reflect Times content categories, such as _Top/News/Sports_
			# * <tt>Facet::COLUMN</tt> - A Times column title (if applicable), such as _Weddings_ or _Ideas & Trends_
			# * <tt>Facet::DATE</tt> - The publication date in YYYYMMDD format
			# * <tt>Facet::DAY_OF_WEEK</tt> - The day of the week (e.g., Monday, Tuesday) the article was published (compare <tt>PUB_DAY</tt>, which is the numeric date rather than the day of the week) 
			# * <tt>Facet::DESCRIPTION</tt> - Descriptive subject terms assigned by Times indexers (must be in UPPERCASE)
			# * <tt>Facet::DESK</tt> - The Times desk that produced the story (e.g., _Business/Financial Desk_)
			# * <tt>Facet::GEO</tt> - Standardized names of geographic locations, assigned by Times indexers (must be in UPPERCASE)
			# * <tt>Facet::MATERIAL_TYPE</tt> - The general article type, such as Biography, Editorial or Review
			# * <tt>Facet::ORGANIZATION</tt> - Standardized names of people, assigned by Times indexers (must be UPPERCASE)
			# * <tt>Facet::PAGE</tt> - The page the article appeared on (in the printed paper)
			# * <tt>Facet::PERSON</tt> - Standardized names of people, assigned by Times indexers. When used in a request, values must be UPPERCASE.
			# * <tt>Facet::PUB_DAY</tt> - The day (DD) segment of date, separated for use as facets
			# * <tt>Facet::PUB_MONTH</tt> - The month (MM) segment of date, separated for use as facets
			# * <tt>Facet::PUB_YEAR</tt> - The year (YYYY) segment of date, separated for use as facets
			# * <tt>Facet::SECTION_PAGE</tt> - The full page number of the printed article (e.g., _D00002_)
			# * <tt>Facet::SOURCE</tt> - The originating body  (e.g., _AP_, _Dow Jones_, _The New York Times_)
			# * <tt>Facet::WORKS_MENTIONED</tt> - Literary works mentioned in the article
			# * <tt>Facet::NYTD_BYLINE</tt> - The article byline, formatted for NYTimes.com
			# * <tt>Facet::NYTD_DESCRIPTION</tt> - Descriptive subject terms, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API). When used in a request, values must be Mixed Case
			# * <tt>Facet::NYTD_GEO</tt> - Standardized names of geographic locations, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API). When used in a request, values must be Mixed Case
			# * <tt>Facet::NYTD_ORGANIZATION</tt> - Standardized names of organizations, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API). When used in a request, values must be Mixed Case
			# * <tt>Facet::NYTD_PERSON</tt> - Standardized names of people, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API). When used in a request, values must be Mixed Case.
			# * <tt>Facet::NYTD_SECTION</tt> - The section the article appears in (on NYTimes.com)
			# * <tt>Facet::NYTD_WORKS_MENTIONED</tt> - Literary works mentioned (titles formatted for use on NYTimes.com)
			#
			# The following two search fields are used for facet searching:
			# * <tt>:only_facets</tt> - takes a single value or array of facets to search. Facets can either be specified as array pairs (like <tt>[Facet::GEOGRAPHIC, 'CALIFORNIA']</tt>) or facets returned from a previous search can be passed directly. A single string can be passed as well if you have hand-crafted string.
			# * <tt>:except_facets</tt> - similar to <tt>:only_facets</tt> but is used to specify a list of facets to exclude.
			#
			# == OTHER SEARCH FIELDS
			# * <tt>:fee</tt> - to be implemented
			# * <tt>:begin_date</tt>, <tt>:end_date</tt> - the parameters are used to specify a start and end date for search results. BOTH of these must be provided or the API will return an error. Accepts either a Time/Date argument or a string of the format YYYYMMDD. For convenience the following alternative methods are provided
			# * <tt>:before</tt> - an alternative to :end_date. Automatically adds a :before_date of sometime in 1980 if no :since argument is also provided; to be implemented
			# * <tt>:since</tt> - An alternative to :begin_date. Automatically adds an :end_date of Time.now if no :before argument is provided; to be implemented.
			# * <tt>:has_thumbnail</tt> - to be implemented
			# * <tt>:has_multimedia</tt> - to be implemented
			#
			# == FACET SUMMARIES
		  # 
		  # The <tt>:facets</tt> argument can be used to specify up to 5 facet fields to be returned alongside the search that provide overall counts
		  # of how much each facet term appears in the search results. FIXME provide list of available facets as well as description of :nytd parameter.
		  #
		  # == ARTICLE FIELDS
		  #
		  # The <tt>:fields</tt> parameter is used to indicate what fields are returned with each article from the search results. If not specified, only
		  # the following fields are returned for each article: body, byline, date, title, and url. To return specific fields, any of the search fields
		  # from above can be explicitly specified in a comma-delimited list, as well as the additional display-only (not searchable) fields below (these
		  # are strings or symbols):
		  # 
		  # * <tt>:all</tt> - return all fields for the article
		  # * <tt>:none</tt> - display only the facet breakdown and no article results
		  # * <tt>:multimedia</tt> - return any related multimedia links for the article
		  # * <tt>:thumbnail</tt> - return information for a related thumbnail image (if the article has one)
		  # * <tt>:word_count</tt> - the word_count of the article.
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
				add_facet_conditions_params(api_params, params)
				add_boolean_params(api_params, params)
				add_facets_param(api_params, params)
				add_fields_param(api_params, params)
				add_rank_params(api_params, params)
				add_date_params(api_params, params)
				add_offset_params(api_params, params)

				reply = invoke(api_params)
				parse_reply(reply)
			end

			private
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


			def self.parse_reply(reply)
				ResultSet.init_from_api(reply)
			end

			def self.add_facets_param(out_params, in_params)
				if in_params[:facets]
					out_params['facets'] = in_params[:facets].to_a.map {|f| Facet.symbol_to_api_name(f)}.join(',')
				end
			end

			def self.field_param(name)
				case name.to_s
				when 'thumbnail'
					IMAGE_FIELDS.join(',')
				else
					name.to_s
				end
			end

			def self.add_fields_param(out_params, in_params)
				case in_params[:fields]
				when nil
					# do nothing
				when :all
					out_params['fields'] = ALL_FIELDS.join(',')
				when :none
					out_params['fields'] = ' '
					unless out_params['facets']
						out_params['facets'] = Facet::DEFAULT_RETURN_FACETS.join(',')
					end
				when String, Symbol
					out_params['fields'] = field_param(in_params[:fields])
				when Array
					out_params['fields'] = in_params[:fields].map {|f| field_param(f)}.join(',')
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
				out_params['query'] = nil if out_params['query'].empty?
			end
			
			def self.facet_argument(name, value, exclude = false)
				unless value.is_a? Array
					value = [value]
				end
				
				if name.is_a? Symbol
					name = Facet.symbol_to_api_name(name)
				end
				
				"#{'-' if exclude}#{name}:[#{value.join(',')}]"
			end

			def self.parse_facet_params(facets, exclude = false)
				facet_args = []
						
				case facets
				when nil
					# do nothing
				when String
					facet_args = [facets]
				when Facet
					facet_args = [facet_argument(facets.facet_type, facets.term, exclude)]
				when Array
					unless facets.all? {|f| f.is_a? Facet }
						raise ArgumentError, "Only Facet instances can be passed in as an array; use Hash for Facet::Name => values input"
					end
					
					facet_hash = {}
					facets.each do |f|
						unless facet_hash[f.facet_type]
							facet_hash[f.facet_type] = []
						end
						
						facet_hash[f.facet_type] << f.term
					end
					
					facet_hash.each_pair do |k,v|
						facet_args << facet_argument(k, v, exclude)
					end
				when Hash
					facets.each_pair do |k,v|
						facet_args << facet_argument(k, v, exclude)
					end
				end
				
				facet_args
			end
			
			def self.add_facet_conditions_params(out_params, in_params)
				query = out_params['query']

				search_facets = parse_facet_params(in_params[:only_facets])
				exclude_facets = parse_facet_params(in_params[:except_facets], true)
				
				unless search_facets.empty? && exclude_facets.empty?
					out_params['query'] = ([query] + search_facets + exclude_facets).compact.join(' ')
				end
			end

			def self.add_boolean_params(out_params, in_params)
				bool_params = []
				query = out_params['query']
				
				unless in_params[:fee].nil?
					bool_params << "#{'-' unless in_params[:fee]}fee:Y"
				end
				
				unless in_params[:has_multimedia].nil?
					bool_params << "#{'-' unless in_params[:has_multimedia]}related_multimedia:Y"
				end
				
				unless in_params[:has_thumbnail].nil?
					bool_params << "#{'-' unless in_params[:has_thumbnail]}small_image:Y"
				end
				
				unless bool_params.empty?
					out_params['query'] = ([query] + bool_params).compact.join(' ')
				end
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