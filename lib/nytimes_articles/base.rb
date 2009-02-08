require 'open-uri'
require 'json'

module Nytimes
	module Articles
		class Base
			API_SERVER = 'api.nytimes.com'
			API_VERSION = 'v1'
			API_NAME = 'articles'
			API_BASE = "/svc/search/#{API_VERSION}/#{API_NAME}"

			@@api_key = nil
			@@copyright = nil

			##
			# The copyright footer to be placed at the bottom of any data from the New York Times. Note this is only set after an API call.
			def self.copyright
				@@copyright
			end

			##
			# Set the API key used for operations. This needs to be called before any requests against the API. To obtain an API key, go to http://developer.nytimes.com/
			def self.api_key=(key)
				@@api_key = key
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
				:query => params.map {|k,v| "#{k}=#{v}"}.join('&')
			end

			def self.invoke(params={})
				begin
					if @@api_key.nil?
						raise AuthenticationError, "You must initialize the API key before you run any API queries"
					end

					full_params = params.merge 'api-key' => @@api_key

					uri = build_request_url(full_params)

					# puts "Request  [#{uri}]"

					reply = uri.read
					parsed_reply = JSON.parse reply

					if parsed_reply.nil?
						# FIXME
						raise "Empty reply returned from API"
					end

					#case parsed_reply['status']
					# FIXME
					#end

					@@copyright = parsed_reply['copyright']

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