module Nytimes
	module Articles
		##
		# If requested in <tt>:fields</tt> for an article search, some articles are returned with a matching thumbnail image. The several thumbnail
		# fields are collected together into a single Thumbnail instance for your convenience. 
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