module Nytimes
	module Articles
		class Facet
			attr_reader :term, :count, :facet_type
			
			# Facet name constants
			CLASSIFIERS = 'classifiers_facet'
			COLUMN = 'column_facet'
			DATE = 'date'
			DAY_OF_WEEK = 'day_of_week_facet'
			DESCRIPTION = 'des_facet'
			DESK = 'desk_facet'
			GEOGRAPHIC = 'geo_facet'
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
			NYTD_GEOGRAPHIC = 'nytd_geo_facet'
			NYTD_ORGANIZATION = 'nytd_org_facet'
			NYTD_PERSON = 'nytd_per_facet'
			NYTD_SECTION = 'nytd_section_facet'
			NYTD_WORKS_MENTIONED = 'nytd_works_mentioned_facet'
			
			# The best 5 facets to return
		  DEFAULT_RETURN_FACETS = [NYTD_DESCRIPTION, NYTD_GEOGRAPHIC, NYTD_ORGANIZATION, NYTD_PERSON, NYTD_SECTION]
		
			ALL_FACETS = [CLASSIFIERS, COLUMN, DATE, DAY_OF_WEEK, DESCRIPTION, DESK, GEOGRAPHIC, MATERIAL_TYPE, ORGANIZATION, PAGE, PERSON, PUB_DAY,
														PUB_MONTH, PUB_YEAR, SECTION_PAGE, SOURCE, WORKS_MENTIONED, NYTD_BYLINE, NYTD_DESCRIPTION, NYTD_GEOGRAPHIC,
														NYTD_ORGANIZATION, NYTD_PERSON, NYTD_SECTION, NYTD_WORKS_MENTIONED]
			
			def initialize(facet_type, term, count)
				@facet_type = facet_type
				@term = term
				@count = count
			end
			
			def self.init_from_api(type, hash)
				self.new(type, hash['term'], hash['count'].to_i)
			end
		end
	end
end