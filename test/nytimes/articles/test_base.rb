require File.dirname(__FILE__) + '/../../test_helper.rb'

class TestNytimes::TestArticles::TestBase < Test::Unit::TestCase
	include Nytimes::Articles
	context "Base.build_request_url" do
		should "call v1 of the API" do
			assert_match %r{v1}, api_url_for 
		end
		
		should "be of the form /svc/search/VERSION/article" do
			assert_match %r{/svc/search/[^/]+/article}, api_url_for
		end
	end
	
	context "Base.invoke" do
		setup do
			init_test_key
		end
		
		context "when the API key has not been set" do
			setup do
				Base.api_key = nil
			end
			
			should "raise an AuthenticationError" do
				assert_raise(AuthenticationError) do
					Base.invoke
				end
			end			
		end
		
		context "when the Articles API returns a 403 forbidden error (API key issue)" do
			setup do
				FakeWeb.register_uri(api_url_for, :status => ["403", "Forbidden"])
			end
			
			should "raise an AuthenticationError" do
				assert_raise(AuthenticationError) do
					Base.invoke
				end
			end
		end
		
		context "when the Articles API returns a 400 bad request error" do
			setup do
				FakeWeb.register_uri(api_url_for, :status => ["400", "Bad Request"])
			end
			
			should "raise an BadRequestError" do
				assert_raise(BadRequestError) do
					Base.invoke
				end
			end
		end
		
		context "When calling the Articles API returns a 500 server error" do
			setup do
				FakeWeb.register_uri(api_url_for, :status => ["500", "Server Error"])
			end
			
			should "raise an ServerError" do
				assert_raise(ServerError) do
					Base.invoke
				end
			end
		end
		
		context "when the Articles API returns any other HTTP error" do
			setup do
				FakeWeb.register_uri(api_url_for, :status => ["502", "Random Error"])
			end
			
			should "raise an ConnectionError" do
				assert_raise(ConnectionError) do
					Base.invoke
				end
			end
		end
		
		context "When the Articles API returns JSON that can't be parsed" do
			setup do
				FakeWeb.register_uri(api_url_for, :text => "e2131421212121221 => 3i109sdfvinp;2 112")
			end
			
			should "raise an BadResponseError" do
				assert_raise(BadResponseError) do
					Base.invoke
				end
			end
		end
		
		context "when passing Integer for offset" do
		  # note Article.search requries integer for offset
		  setup do
				FakeWeb.register_uri(api_url_for('offset' => '1'), :status => ['200', 'OK'], :string => '{}')
			end
		  
		  should "not raise NoMethodError" do
		    assert_nothing_raised(NoMethodError) { Base.invoke('offset' => 1) }
	    end
	  end
	end
	
	context "Base#text_field" do
    context "when decode_html_entities == true" do
      should "decode HTML entities in text fields" do
        assert_equal "foó", Base.text_field("fo&oacute;")
      end
    end
    
    context "when decode_html_entities == false" do
      setup { Base.decode_html_entities = false }
      teardown { Base.decode_html_entities = true }
      
      should "not decode HTML entities in text fields" do
        assert_equal "fo&oacute;", Base.text_field("fo&oacute;")
      end
    end
  end
end