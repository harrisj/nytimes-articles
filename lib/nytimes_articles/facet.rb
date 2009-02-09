module Nytimes
	module Articles
		class Facet
			attr_reader :term, :count, :facet_type
			
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