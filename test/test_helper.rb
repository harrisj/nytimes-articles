require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
gem 'fakeweb'
require 'fake_web'

FakeWeb.allow_net_connect = false

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nytimes_articles'

API_KEY = '13e234323232222'

def init_test_key
	Nytimes::Articles::Base.api_key = API_KEY
end

def api_url_for(params = {})
	full_params = params.merge 'api-key' => API_KEY
	Nytimes::Articles::Base.build_request_url(full_params).to_s
end

module TestNytimes
	module TestArticles
	end
end

class Test::Unit::TestCase
end

