module Nytimes
	module Articles
		
		##
		# This class represents a Facet used in the ArticleSearch API. Facets can be used to both search for matching articles (see Article#search) and
		# are also returned as article and search metadata. Facets are made up of 3 parts:
		# * <tt>facet_type</tt> - a string; see Article#search for a list of facet types
		# * <tt>term</tt> - a string as well
		# * <tt>count</tt> - Facets returned as search metadata (via the <tt>:facets</tt> parameter to Article#search) also include a non-nil count of matching articles for that facet
		class Facet
			##
			# The term for the facet
			attr_reader :term
			
			##
			# The number of times this facet has appeared in the search results (note: this only applies for facets returned in the facets header on an Article#search)
			attr_reader :count
			
			##
			# The facet type
			attr_reader :facet_type
			
			# Facet name constants
			CLASSIFIERS = 'classifiers_facet'
			COLUMN = 'column_facet'
			DATE = 'date'
			DAY_OF_WEEK = 'day_of_week_facet'
			DESCRIPTION = 'des_facet'
			DESK = 'desk_facet'
			GEO = 'geo_facet'
			MATERIAL_TYPE = 'material_type_facet'
			ORGANIZATION = 'org_facet'
			PAGE = 'page_facet'
			PERSON = 'per_facet'
			PUB_DAY = 'publication_day'
			PUB_MONTH = 'publication_month'
			PUB_YEAR = 'publication_year'
			SECTION_PAGE = 'section_page_facet'
			SOURCE = 'source_facet'
			WORKS_MENTIONED = 'works_mentioned_facet'
			
			# Facets of content formatted for nytimes.com
			NYTD_BYLINE = 'nytd_byline'
			NYTD_DESCRIPTION = 'nytd_des_facet'
			NYTD_GEO = 'nytd_geo_facet'
			NYTD_ORGANIZATION = 'nytd_org_facet'
			NYTD_PERSON = 'nytd_per_facet'
			NYTD_SECTION = 'nytd_section_facet'
			NYTD_WORKS_MENTIONED = 'nytd_works_mentioned_facet'
			
			# The default 5 facets to return
		  DEFAULT_RETURN_FACETS = [DESCRIPTION, GEO, ORGANIZATION, PERSON, DESK]
		
			ALL_FACETS = [CLASSIFIERS, COLUMN, DATE, DAY_OF_WEEK, DESCRIPTION, DESK, GEO, MATERIAL_TYPE, ORGANIZATION, PAGE, PERSON, PUB_DAY,
														PUB_MONTH, PUB_YEAR, SECTION_PAGE, SOURCE, WORKS_MENTIONED, NYTD_BYLINE, NYTD_DESCRIPTION, NYTD_GEO,
														NYTD_ORGANIZATION, NYTD_PERSON, NYTD_SECTION, NYTD_WORKS_MENTIONED]
			
			##
			# Initializes the facet. There is seldom a reason for you to call this.
			def initialize(facet_type, term, count)
				@facet_type = facet_type
				@term = term
				@count = count
			end
			
			##
			# Takes a symbol name and subs it to a string constant
			def self.symbol_name(facet)
				case facet
				when String
					return facet
				when Facet
					return facet.facet_type
				when Symbol
					# fall through
				else
					raise ArgumentError, "Unsupported type to Facet#symbol_to_api_name"
				end
				
				case facet
				when :geography
					GEO
				when :org, :orgs
					ORGANIZATION
				when :people
					PERSON
				when :nytd_geography
					NYTD_GEO
				when :nytd_org, :nytd_orgs
					NYTD_ORGANIZATION
				when :nytd_people
					NYTD_PERSON
				else
					name = facet.to_s.upcase
					
					if const_defined?(name)
						const_get(name)
					elsif name =~ /S$/ && const_defined?(name.gsub(/S$/, ''))
						const_get(name.gsub(/S$/, ''))
					else
						raise ArgumentError, "Unable to find a matching facet key for symbol :#{facet}"
					end
				end
			end
			
			##
			# Initializes a selection of Facet objects returned from the API. Used for marshaling Facets in articles and metadata from search results
			# (Note: some facets are returned as scalar values)
			def self.init_from_api(api_hash)
				return nil if api_hash.nil?
				
				unless api_hash.is_a? Hash
					raise ArgumentError, "expecting a Hash only"
				else
					return nil if api_hash.empty?
				end
				
				out = {}
				
				api_hash.each_pair do |k,v|
					out[k] = v.map {|f| Facet.new(k, f['term'], f['count'])}
				end
				
				out
			end
		end
	end
end