module Nytimes
	module Articles
		class Error < ::RuntimeError
		end
		
		class AuthenticationError < Error
		end
		
		class BadRequestError < Error
		end
		
		class BadResponseError < Error
		end
		
		class ServerError < Error
		end
		
		class TimeoutError < Error
		end
		
		class ConnectionError < Error
		end
	end
end