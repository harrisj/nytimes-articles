module Nytimes
	module Articles
		##
		# The generic Error class from which all other Errors are derived.
		class Error < ::RuntimeError
		end
		
		##
		# This error is thrown if there are problems authenticating your API key.
		class AuthenticationError < Error
		end
		
		##
		# This error is thrown if the request was not parsable by the API server.
		class BadRequestError < Error
		end
		
		##
		# This error is thrown if the response from the API server is not parsable.
		class BadResponseError < Error
		end
		
		##
		# This error is thrown if there is an error connecting to the API server.
		class ServerError < Error
		end
		
		##
		# This error is thrown if there is a timeout connecting to the server (to be implemented).
		class TimeoutError < Error
		end
		
		##
		# This error is thrown for general connection errors to the API server.
		class ConnectionError < Error
		end
	end
end