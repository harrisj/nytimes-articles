require File.dirname(__FILE__) + '/../../test_helper.rb'

class TestNytimes::TestArticles::TestBase < Test::Unit::TestCase
	context "Base.build_request_url" do
	end
	
	context "Base.invoke" do
		context "when the API key has not been set" do
			should "raise an AuthenticationError" do
			end
			
			should "not send the request through to the NYTimes' API server"
		end
		
		context "when the Articles API returns a 403 forbidden error (API key issue)" do
			should "raise an AuthenticationError"
		end
		
		context "when the Articles API returns a 400 bad request error" do
			should "raise an BadRequestError"
		end
		
		context "When calling the Articles API returns a 500 server error" do
			should "raise a ServerError"
		end
		
		context "When the Articles API returns JSON that can't be parsed" do
			should "raise a BadResponseError"
		end
	end
end