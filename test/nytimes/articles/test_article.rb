require File.dirname(__FILE__) + '/../../test_helper.rb'

class TestNytimes::TestArticles::TestArticle < Test::Unit::TestCase
	include Nytimes::Articles
	
	def setup
		init_test_key
	end
	
	context "attributes" do
		setup do
			@article = Article.new
		end
		
		%w(abstract author body byline).each do |text_field|
			should_eventually "return a string for the #{text_field} attribute" do
				assert_kind_of String, @article.send(text_field)
			end
			
			should "only allow read-only access for the attribute" do
				assert !@article.respond_to?("#{text_field}=")
			end
		end
	end
	
	context "Article.search" do
		should "accept a String for the first argument that is passed through to the query in the API" do
			Article.expects(:invoke).with(has_entry("query", "FOO BAR"))
			Article.search "FOO BAR"
		end
		
		should "accept a Hash for the first argument"
		
		context "date ranges" do
			should "pass a string argument to begin_date straight through" do
				date = "20081212"
				Article.expects(:invoke).with(has_entry("begin_date", date))
				Article.search :begin_date => date
			end
			
			should "convert begin_date from a Date or Time to YYYYMMDD format" do
				time = Time.now
				Article.expects(:invoke).with(has_entry("begin_date", time.strftime("%Y%m%d")))
				Article.search :begin_date => time
			end
			
			should "pass a string argument to end_date straight through" do
				date = "20081212"
				Article.expects(:invoke).with(has_entry("end_date", date))
				Article.search :end_date => date
			end
			
			should "convert end_date from a Date or Time to YYYYMMDD format" do
				time = Time.now
				Article.expects(:invoke).with(has_entry("end_date", time.strftime("%Y%m%d")))
				Article.search :end_date => time
			end
			
			should "raise an ArgumentError if the begin_date is NOT a string and does not respond_to strftime" do
				assert_raise(ArgumentError) { Article.search :begin_date => 23 }
			end
			
			should "raise an ArgumentError if the end_date is NOT a string and does not respond_to strftime" do
				assert_raise(ArgumentError) { Article.search :end_date => 23 }
			end
			
			# should "accept a date_range argument with a begin and end date argument"
		end
		
		context "facets" do
			
		end
		
		context "offset" do
			should "pass through an explicit offset parameter if specified" do
				Article.expects(:invoke).with(has_entry("offset", 10))
				Article.search :offset => 10
			end
			
			should "raise an ArgumentError if the offset is not an Integer" do
				assert_raise(ArgumentError) { Article.search :offset => 'apple' }
			end
			
			should "pass through an offset of page - 1 if :page is used instead" do
				Article.expects(:invoke).with(has_entry("offset", 2))
				Article.search :page => 3
			end
			
			should "not pass through a page parameter to the API" do
				Article.expects(:invoke).with(Not(has_key("page")))
				Article.search :page => 3
			end
			
			should "raise an ArgumentError if the page is not an Integer" do
				assert_raise(ArgumentError) { Article.search :page => 'orange' }
			end
			
			should "use the :offset argument if both an :offset and :page are provided" do
				Article.expects(:invoke).with(has_entry("offset", 2))
				Article.search :offset => 2, :page => 203
			end
		end
		
		context "rank" do
			%w(newest oldest closest).each do |rank|
				should "accept #{rank} as the argument to rank" do
					Article.expects(:invoke).with(has_entry("rank", rank))
					Article.search :rank => rank.to_sym
				end
			end
			
			should "raise an ArgumentError if rank is something else" do
				assert_raise(ArgumentError) { Article.search :rank => :clockwise }
			end
		end
		
		context "query parameters" do
			context "abstract" do
				should "be prefixed with the abstract: field identifier in the query"
				should "cast the argument to a string (will figure out processing later)"
			end
			
			context "author" do
				should "be prefixed with the author: field identifier in the query"
				should "cast the argument to a string (will figure out processing later)"
			end
			
			context "body" do
				should "be prefixed with the body: field identifier in the query"
				should "cast the argument to a string (will figure out processing later)"
			end
			
			context "byline" do
				should "be prefixed with the body: field identifier in the query"
				should "cast the argument to a string (will figure out processing later)"
			end
			
			context "classifiers" do
				should "be prefixed with classifiers_facet"
				should "send arguments as an array"
				should "accept either string or Facet object for each array element"
			end
		end
	end
	
	context "Article.init_from_hash" do
		
	end
end


# abstract 	String 	X 	  	X 	A summary of the article, written by Times indexers
# author 	String 	X 	  	X 	An author note, such as an e-mail address or short biography (compare byline)
# body 	String 	X 	  	X 	A portion of the beginning of the article. Note: Only a portion of the article body is included in responses. But when you search against the body field, you search the full text of the article.
# byline 	String 	X 	  	X 	The article byline, including the author's name
# classifers_facet 	Array (Strings) 	  	X 	X 	Taxonomic classifiers that reflect Times content categories, such as Top/News/Sports
# column_facet 	String 	  	X 	X 	A Times column title (if applicable), such as  Weddings or Ideas & Trends
# date 	Date 	  	X 	X 	The publication date in YYYYMMDD format
# day_of_week_facet 	String 	  	X 	X 	The day of the week (e.g., Monday, Tuesday) the article was published (compare publication_day, which is the numeric date rather than the day of the week)
# des_facet 	Array (Strings) 	  	X 	X 	Descriptive subject terms assigned by Times indexers
# 
# When used in a request, values must be UPPERCASE
# desk_facet
# desk_facet 	String 	  	X 	X 	The Times desk that produced the story (e.g., Business/Financial Desk)
# fee 	Boolean 	X 	  	X 	Indicates whether users must pay a fee to retrieve the full article
# geo_facet 	Array (Strings) 	  	X 	X 	Standardized names of geographic locations, assigned by Times indexers
# 
# When used in a request, values must be UPPERCASE
# lead_paragraph 	String 	X 	  	X 	The first paragraph of the article (as it appeared in the printed newspaper)
# material_type_facet 	Array (Strings) 	  	X 	X 	The general article type, such as Biography, Editorial or Review
# multimedia 	Array 	  	  	X 	Associated multimedia features, including URLs (see also the related_multimedia field)
# nytd_byline_facet 	String 	  	X 	X 	The article byline, formatted for NYTimes.com
# nytd_des_facet 	Array (Strings) 	  	X 	X 	Descriptive subject terms, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API)
# 
# When used in a request, values must be Mixed Case
# nytd_geo_facet 	Array (Strings) 	  	X 	X 	Standardized names of geographic locations, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API)
# 
# When used in a request, values must be Mixed Case
# nytd_lead_paragraph 	String 	X 	  	X 	The first paragraph of the article (as it appears on NYTimes.com)
# nytd_org_facet 	Array (Strings) 	  	X 	X 	Standardized names of organizations, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API)
# 
# When used in a request, values must be Mixed Case
# nytd_per_facet 	Array (Strings) 	  	X 	X 	Standardized names of people, assigned for use on NYTimes.com (to get standardized terms, use the TimesTags API)
# 
# When used in a request, values must be Mixed Case
# nytd_section_facet 	Array (Strings) 	  	X 	X 	The section the article appears in (on NYTimes.com)
# nytd_title 	String 	X 	  	X 	The article title on NYTimes.com (this field may or may not match the title field; headlines may be shortened and edited for the Web)
# nytd_works_mentioned
# _facet 	String 	  	X 	X 	Literary works mentioned (titles formatted for use on NYTimes.com)
# org_facet 	Array (Strings) 	  	X 	X 	Standardized names of organizations, assigned by Times indexers
# 
# When used in a request, values must be UPPERCASE
# page_facet 	String 	  	X 	X 	The page the article appeared on (in the printed paper)
# per_facet 	Array (Strings) 	  	X 	X 	Standardized names of people, assigned by Times indexers
# 
# When used in a request, values must be UPPERCASE
# publication_day
# publication_month
# publication_year 	Date
# Date
# Date 	  	X
# X
# X 	X
# x
# x 	The day (DD), month (MM) and year (YYYY) segments of date, separated for use as facets
# related_multimedia 	Boolean 	X 	  	X 	Indicates whether multimedia features are associated with this article. Additional metadata for each related multimedia feature appears in the multimedia array.
# section_page_facet 	String 	  	X 	X 	The full page number of the printed article (e.g., D00002)
# small_image
# small_image_url
# small_image_height
# small_image_width 	Boolean
# String
# Integer
# Integer 	X 	  	X
# X
# X
# X 	The small_image field indicates whether a smaller thumbnail image is associated with the article. The small_image_url field provides the URL of the image on NYTimes.com. The small_image_height and small_image_width fields provide the image dimensions.
# source_facet 	String 	  	X 	X 	The originating body  (e.g., AP, Dow Jones, The New York Times)
# text 	String 	X 	  	  	The text field consists of title + byline + body (combined in an OR search) and is the default field for keyword searches. For more information, see Constructing a Search Query.
# title 	String 	X 	  	X 	The article title (headline); corresponds to the headline that appeared in the printed newspaper
# url 	String 	X 	  	X 	The URL of the article on NYTimes.com
# word_count 	Integer 	  	  	X 	The full article word count
# works_mentioned_facet