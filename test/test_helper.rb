require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nytimes_articles'

API_KEY = '13e234323232222'
Nytimes::Articles::Base.api_key = API_KEY

def api_url_for(path, params = {})
	full_params = params.merge 'api-key' => API_KEY
	Nytimes::Articles::Base.build_request_url(path, full_params).to_s
end

module TestNytimes
	module TestArticles
	end
end

class Test::Unit::TestCase
end

