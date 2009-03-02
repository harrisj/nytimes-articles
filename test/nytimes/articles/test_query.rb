require File.dirname(__FILE__) + '/../../test_helper.rb'

class TestNytimes::TestArticles::TestQuery < Test::Unit::TestCase
	include Nytimes::Articles

  def setup
    Base.stubs(:invoke)
    @query = Query.new
  end

  def assert_has_accessor(obj, name, value='foo')
    assert_nothing_raised { obj.send("#{name}=", value) }
    assert_equal value, obj.send(name)
  end

  def expect_search_with(hsh)
    Article.expects(:search).with(has_entry(hsh))
  end

  def self.should_proxy_search_param(name, value)
    should "provide accessor for :#{name}" do
      assert_has_accessor(@query, name, value)
    end

    should "pass :#{name} to Article#search" do
      @query.send("#{name}=", value)
      expect_search_with name => value
      @query.perform      
    end
  end

  context "proxying named parameters to Article.search" do
    (Article::TEXT_FIELDS + [:query]).each do |name|
      should_proxy_search_param name.to_sym, 'some text field'
    end

    [:only_facets, :except_facets].each do |name|
      should_proxy_search_param name, {'geo_facet' => 'NEW YORK CITY'}
    end

    [:begin_date, :end_date, :since, :before].each do |name|
      should_proxy_search_param name, Time.now
    end

    [:fee, :has_thumbnail].each do |name|
      should_proxy_search_param name, true
    end

    should_proxy_search_param :facets, ['geo_facet', 'org_facet', 'per_facet']
    should_proxy_search_param :fields, ['title', 'abstract']
    should_proxy_search_param :offset, 99
    
    should "not pass nil parameters" do
      @query.query = 'foo'
      Article.expects(:search).with(:query => 'foo')
      @query.perform
    end
  end
  
  context "generating hash" do
    # not sure how one would test this exhaustively, going for coverage + non-regression...
    
    should "produce the same hash for identical queries" do
      q0 = Query.new
      q0.query = 'foo bar baz'
      q0.only_facets = {'geo_facet' => 'NEW YORK CITY'}
      
      q1 = Query.new
      q1.query = 'foo bar baz'
      q1.only_facets = {'geo_facet' => 'NEW YORK CITY'}
      
      assert_equal q0.hash, q1.hash
    end
    
    should "not produce the same hash for non-identical queries" do
      q0 = Query.new; q0.query = 'foo'
      q1 = Query.new; q1.query = 'bar'
      assert_not_equal q0.hash, q1.hash
      
      q0 = Query.new; q0.facets = {'geo_facet' => 'NEW YORK CITY'}
      q1 = Query.new; q1.facets = {'geo_facet' => 'CALIFORNIA'}
      assert_not_equal q0.hash, q1.hash
      
      q0 = Query.new; q0.since = Date.parse('1/1/2009')
      q1 = Query.new; q1.since = Date.parse('1/2/2009')
      assert_not_equal q0.hash, q1.hash
    end
  end
end