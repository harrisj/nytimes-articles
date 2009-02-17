module Nytimes
	module Articles
		class Thumbnail
			attr_reader :url, :width, :height
			
			def initialize(url, width, height)
				@url = url
				@width = width
				@height = height
			end
			
			def self.init_from_api(api_hash)
				return nil unless !api_hash.nil? && api_hash['small_image_url']
				
				unless api_hash['small_image_width'].nil?
					width = api_hash['small_image_width'].to_i
				end
				
				unless api_hash['small_image_height'].nil?
					height = api_hash['small_image_height'].to_i
				end
				
				new(api_hash['small_image_url'], width, height)
			end
		end
	end
end