require File.dirname(__FILE__) + '/../../test_helper.rb'

class TestNytimes::TestArticles::TestThumbnail < Test::Unit::TestCase
	include Nytimes::Articles
	
	context "read-only attributes" do
		setup do
			@thumbnail = Thumbnail.new("http://www.foo.com", 400, 600)
		end
		
		%w(url width height).each do |field|
			should "have a #{field} attribute" do
				assert @thumbnail.respond_to?(field)
			end
			
			should "be read-only for the #{field} attribute" do
				assert_raise(NoMethodError) do
					@thumbnail.send "#{field}=", "new value"
				end
			end
		end
	end
	
	context "Facet.init_from_api" do
		setup do
			@hash = {"small_image_url" => "http://foo.com/", 'small_image_width' => '400', 'small_image_height' => '600'}
		end
		
		should "return nil if reply from API has no URL" do
			assert_nil Thumbnail.init_from_api(nil)
			assert_nil Thumbnail.init_from_api({})
		end
		
		%w(width height).each do |dimension|
			should "set to nil if it is nil in the array" do
				@hash["small_image_#{dimension}"] = nil
				thumbnail = Thumbnail.init_from_api(@hash)
				assert_nil thumbnail.send(dimension)
			end
			
			should "cast to an Integer value if passed a string" do
				thumbnail = Thumbnail.init_from_api(@hash)
				assert_equal @hash["small_image_#{dimension}"].to_i, thumbnail.send(dimension)
			end
		end
	end
end