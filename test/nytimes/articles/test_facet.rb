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
	
	context "Facet.symbol_to_api_name" do
		[:geo, :geography].each do |sym|
			should "return Facet::GEO for #{sym}" do
				assert_equal Facet::GEO, Facet.symbol_to_api_name(sym)
			end
		end

		[:org, :orgs, :organization, :organizations].each do |sym|
			should "return Facet::ORGANIZATION for #{sym}" do
				assert_equal Facet::ORGANIZATION, Facet.symbol_to_api_name(sym)
			end
		end
		
		[:people, :person, :persons].each do |sym|
			should "return Facet::PERSON for #{sym}" do
				assert_equal Facet::PERSON, Facet.symbol_to_api_name(sym)
			end
		end
		
		[:nytd_geo, :nytd_geography].each do |sym|
			should "return Facet::NYTD_GEO for #{sym}" do
				assert_equal Facet::NYTD_GEO, Facet.symbol_to_api_name(sym)
			end
		end

		[:nytd_org, :nytd_orgs, :nytd_organization, :nytd_organizations].each do |sym|
			should "return Facet::NYTD_ORGANIZATION for #{sym}" do
				assert_equal Facet::NYTD_ORGANIZATION, Facet.symbol_to_api_name(sym)
			end
		end
		
		[:nytd_people, :nytd_person, :nytd_persons].each do |sym|
			should "return Facet::NYTD_PERSON for #{sym}" do
				assert_equal Facet::NYTD_PERSON, Facet.symbol_to_api_name(sym)
			end
		end
		
		should "look for a matching constant and use that value" do
			assert_equal Facet::SOURCE, Facet.symbol_to_api_name(:source)
		end
		
		should "singularize the symbol when looking for a constant if no match for the plural form" do
			assert_equal Facet::PAGE, Facet.symbol_to_api_name(:pages)
		end
		
		should "raise an ArgumentError if not passed a symbol" do
			assert_raise(ArgumentError) { Facet.symbol_to_api_name(23) }
		end
		
		should "raise an ArgumentError if unable to find a matching Facet constant" do
			assert_raise(ArgumentError) { Facet.symbol_to_api_name(:clown) }
		end
	end
end