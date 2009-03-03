require 'open-uri'
require 'json'
require 'htmlentities'

module Nytimes
	module Articles
		class Base
			API_SERVER = 'api.nytimes.com'
			API_VERSION = 'v1'
			API_NAME = 'article'
			API_BASE = "/svc/search/#{API_VERSION}/#{API_NAME}"

			@@api_key = nil
			@@debug = false
			@@decode_html_entities = true

			##
			# Set the API key used for operations. This needs to be called before any requests against the API. To obtain an API key, go to http://developer.nytimes.com/
			def self.api_key=(key)
				@@api_key = key
			end
			
			def self.debug=(flag)
				@@debug = flag
			end
			
			##
			# Set whether or not to decode HTML entities when returning text fields.
			def self.decode_html_entities=(flag)
			  @@decode_html_entities = flag
		  end

			##
			# Returns the current value of the API Key
			def self.api_key
				@@api_key
			end

			##
			# Builds a request URI to call the API server
			def self.build_request_url(params)
				URI::HTTP.build :host => API_SERVER,
				:path => API_BASE,
				:query => params.map {|k,v| "#{URI.escape(k)}=#{URI.escape(v)}"}.join('&')
			end
			
			def self.text_field(value)
				return nil if value.nil?
				@@decode_html_entities ? HTMLEntities.new.decode(value) : value
			end
			
			def self.integer_field(value)
				return nil if value.nil?
				value.to_i
			end
			
			def self.date_field(value)
				return nil unless value =~ /^\d{8}$/
				Date.strptime(value, "%Y%m%d")
			end
			
			def self.boolean_field(value)
				case value
				when nil
					false
				when TrueClass
					true
				when FalseClass
					false
				when 'Y'
					true
				when 'N'
					false
				else
					false
				end
			end

			def self.invoke(params={})
				begin
					if @@api_key.nil?
						raise AuthenticationError, "You must initialize the API key before you run any API queries"
					end

					full_params = params.merge 'api-key' => @@api_key
					uri = build_request_url(full_params)	
					
					puts "REQUEST: #{uri}" if @@debug
						
					reply = uri.read
					parsed_reply = JSON.parse reply

					if parsed_reply.nil?
						raise BadResponseError, "Empty reply returned from API"
					end

					#case parsed_reply['status']
					# FIXME
					#end

					parsed_reply
				rescue OpenURI::HTTPError => e
					# FIXME: Return message from body?
					case e.message
					when /^400/
						raise BadRequestError
					when /^403/
						raise AuthenticationError
					when /^404/
						return nil
					when /^500/
						raise ServerError
					else
						raise ConnectionError
					end

					raise "Error connecting to URL #{uri} #{e}"
				rescue JSON::ParserError => e
					raise BadResponseError, "Invalid JSON returned from API:\n#{reply}"
				end
			end
		end
	end
end