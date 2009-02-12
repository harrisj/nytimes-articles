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
			@hash = {"date" => [{"count" => 36 , "term" => "19960630"} , {"count" => 36 , "term" => "19990523"}]}
			@facets = Facet.init_from_api(@hash)
		end
		
		should "return nil if reply from API has no facets section" do
			assert_nil Facet.init_from_api(nil)
		end
		
		should "return a hash indexed by the facet name from the API" do
			assert_kind_of(Hash, @facets)
			assert_same_elements @hash.keys, @facets.keys
		end
		
		should "return an array of Facet objects as the value for a key" do
			first_key = @facets.keys.first
			assert_kind_of Array, @facets[first_key]
			assert @facets[first_key].all? {|f| f.is_a? Facet }
			assert @facets[first_key].all? {|f| f.facet_type == first_key }
		end
	end
end