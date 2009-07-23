module Nytimes
	module Articles
		class FacetHash
			def initialize(hash)
				@facets = hash
			end
			
			def [](key)
				case key
				when Symbol
					key = Facet.symbol_name(key)
				when String
					# do nothing
				else
					raise ArgumentError, "Argument to facets hash must be a symbol or string name"
				end
				
				@facets[key]
			end
			
			def self.init_from_api(hash)
				new(hash)
			end
		end
	end
end