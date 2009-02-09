require File.dirname(__FILE__) + '/../../test_helper.rb'

class TestNytimes::TestArticles::TestFacet < Test::Unit::TestCase
	include Nytimes::Articles
	
	context "read-only attributes" do
		setup do
			@facet = Facet.new("facet_type", "term", 103)
		end
		
		%w(term count facet_type).each do |field|
			should "have a #{field} attribute" do
				assert @facet.respond_to?(field)
			end
			
			should "be read-only for the #{field} attribute" do
				assert_raise(NoMethodError) do
					@facet.send "#{field}=", "new value"
				end
			end
		end
	end
	
	context "Facet.init_from_api" do
		setup do
			@facet_type = :geo
			@term = "Brookyln, NY"
			@api_hash = {"term" => @term, "count" => "92"}
			@facet = Facet.init_from_api(@facet_type, @api_hash)
		end

		should "take the facet_type as the first argument" do
			assert_equal :geo, @facet.facet_type
		end
		
		should "accept the hash for the facet as the second argument" do
			assert_equal @term, @facet.term
		end
		
		should "return a valid Facet instance" do
			assert_kind_of Facet, @facet
		end
		
		should "handle the count being a string on the input" do
			assert_equal 92, @facet.count
		end
	end
end