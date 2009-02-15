require File.dirname(__FILE__) + '/../../test_helper.rb'

ARTICLE_API_HASH = {"page_facet"=>"8", "lead_paragraph"=>"", "classifiers_facet"=>["Top/News/Business", "Top/Classifieds/Job Market/Job Categories/Banking, Finance and Insurance", "Top/News/Business/Markets"], "title"=>"Wall St. Treads Water as It Waits on Washington", "nytd_title"=>"Wall St. Treads Water as It Waits on Washington", "byline"=>"By JACK HEALY", "body"=>"Wall Street held its breath on Monday as it awaited details on a banking bailout from Washington. Investors had expected to start the week with an announcement from the Treasury Department outlining its latest plans to stabilize the financial system. But the Obama administration delayed releasing the details until at least Tuesday to keep the focus", "material_type_facet"=>["News"], "url"=>"http://www.nytimes.com/2009/02/10/business/10markets.html", "publication_month"=>"02", "date"=>"20090210", "publication_year"=>"2009", "nytd_section_facet"=>["Business"], "source_facet"=>"The New York Times", "desk_facet"=>"Business", "publication_day"=>"10", "des_facet"=>["STOCKS AND BONDS"], "day_of_week_facet"=>"Tuesday"}

ARTICLE_API_HASH2 = {"page_facet"=>"29", "lead_paragraph"=>"", "geo_facet"=>["WALL STREET (NYC)"], "small_image_width"=>"75", "classifiers_facet"=>["Top/News/New York and Region", "Top/Classifieds/Job Market/Job Categories/Education", "Top/Features/Travel/Guides/Destinations/North America", "Top/Classifieds/Job Market/Job Categories/Banking, Finance and Insurance", "Top/Features/Travel/Guides/Destinations/North America/United States/New York", "Top/Features/Travel/Guides/Destinations/North America/United States", "Top/News/Education"], "title"=>"OUR TOWNS; As Pipeline to Wall Street Narrows, Princeton Students Adjust Sights", "nytd_title"=>"As Pipeline to Wall Street Narrows, Princeton Students Adjust Sights", "byline"=>"By PETER APPLEBOME", "body"=>"Princeton, N.J. There must be a screenplay in the fabulous Schoppe twins, Christine and Jennifer, Princeton University juniors from Houston. They had the same G.P.A. and SATs in high school, where they became Gold Award Girl Scouts , sort of the female version of Eagle Scouts. They live together and take all the same courses, wear identical necklac", "material_type_facet"=>["News"], "url"=>"http://www.nytimes.com/2009/02/08/nyregion/08towns.html", "publication_month"=>"02", "small_image_height"=>"75", "date"=>"20090208", "column_facet"=>"Our Towns", "small_image"=>"Y", "publication_year"=>"2009", "nytd_section_facet"=>["New York and Region", "Education"], "source_facet"=>"The New York Times", "org_facet"=>["PRINCETON UNIVERSITY"], "desk_facet"=>"New York Region", "publication_day"=>"08", "small_image_url"=>"http://graphics8.nytimes.com/images/2009/02/08/nyregion/08towns.751.jpg", "des_facet"=>["EDUCATION AND SCHOOLS", "BANKS AND BANKING"], "day_of_week_facet"=>"Sunday"}

class TestNytimes::TestArticles::TestArticle < Test::Unit::TestCase
	include Nytimes::Articles

	def setup
		init_test_key
		Article.stubs(:parse_reply)
	end

	context "Article.search" do
		should "accept a String for the first argument that is passed through to the query in the API" do
			Article.expects(:invoke).with(has_entry("query", "FOO BAR"))
			Article.search "FOO BAR"
		end

		should "accept a Hash for the first argument" do
			Article.expects(:invoke).with(has_entry("query", "FOO BAR"))
			Article.search :query => 'FOO BAR', :page => 2
		end

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

			context ":before" do
				should "add a begin_date in 1980 if no :since or :begin_date argument is provided"
				should "not add a begin_date is there is a :since argument"
				should "not add a begin_date if there is a :begin_date argument already"
			end
			
			context ":since" do
				should "add an end_date of now if no :before or :end_date argument is provided"
				should "not add an end_date is there is a :before argument"
				should "not add an end_date if there is a :end_date argument already"
			end
		end

		context "facets" do
			should "accept a single string" do
				Article.expects(:invoke).with(has_entry("facets", Facet::DATE))
				Article.search "FOO BAR", :facets => Facet::DATE
			end

			should "accept an array of strings" do
				Article.expects(:invoke).with(has_entry("facets", [Facet::DATE, Facet::GEOGRAPHIC].join(',')))
				Article.search "FOO BAR", :facets => [Facet::DATE, Facet::GEOGRAPHIC]
			end
		end
		
		context "search_facets" do
			should "accept a String" do
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search :search_facets => "#{Facet::GEOGRAPHIC}:[CALIFORNIA]"
			end
			
			should "accept a single hash value Facet string to a term" do
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search :search_facets => {Facet::GEOGRAPHIC => 'CALIFORNIA'}
			end
			
			should "accept an Facet string hashed to an array terms" do
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEOGRAPHIC}:[CALIFORNIA,GREAT BRITAIN]"))
				Article.search :search_facets => {Facet::GEOGRAPHIC => ['CALIFORNIA', 'GREAT BRITAIN']}
			end
			
			should "accept a single Facet object" do
				f = Facet.new(Facet::GEOGRAPHIC, 'CALIFORNIA', 2394)
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search :search_facets => f
			end
			
			should "accept an array of Facet objects" do
				f = Facet.new(Facet::GEOGRAPHIC, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::NYTD_ORGANIZATION, 'University Of California', 12)
				
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEOGRAPHIC}:[CALIFORNIA] #{Facet::NYTD_ORGANIZATION}:[University Of California]"))
				Article.search :search_facets => [f, f2]
			end
			
			should "merge multiple Facets objects in the array of the same type into one array" do
				f = Facet.new(Facet::GEOGRAPHIC, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::GEOGRAPHIC, 'IOWA', 12)
				
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEOGRAPHIC}:[CALIFORNIA,IOWA]"))
				Article.search :search_facets => [f, f2]
			end
			
			should "not stomp on an existing query string" do
				Article.expects(:invoke).with(has_entry("query", "ice cream #{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search "ice cream", :search_facets => {Facet::GEOGRAPHIC => "CALIFORNIA"}
			end
		end

		context "exclude_facets" do
			should "accept a String" do
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search :exclude_facets => "-#{Facet::GEOGRAPHIC}:[CALIFORNIA]"
			end
			
			should "accept a single hash value Facet string to a term" do
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search :exclude_facets => {Facet::GEOGRAPHIC => 'CALIFORNIA'}
			end
			
			should "accept an Facet string hashed to an array terms" do
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEOGRAPHIC}:[CALIFORNIA,GREAT BRITAIN]"))
				Article.search :exclude_facets => {Facet::GEOGRAPHIC => ['CALIFORNIA', 'GREAT BRITAIN']}
			end
			
			should "accept a single Facet object" do
				f = Facet.new(Facet::GEOGRAPHIC, 'CALIFORNIA', 2394)
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search :exclude_facets => f
			end
			
			should "accept an array of Facet objects" do
				f = Facet.new(Facet::GEOGRAPHIC, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::NYTD_ORGANIZATION, 'University Of California', 12)
				
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEOGRAPHIC}:[CALIFORNIA] -#{Facet::NYTD_ORGANIZATION}:[University Of California]"))
				Article.search :exclude_facets => [f, f2]
			end
			
			should "merge multiple Facets objects in the array of the same type into one array" do
				f = Facet.new(Facet::GEOGRAPHIC, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::GEOGRAPHIC, 'IOWA', 12)
				
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEOGRAPHIC}:[CALIFORNIA,IOWA]"))
				Article.search :exclude_facets => [f, f2]
			end
			
			should "not stomp on an existing query string" do
				Article.expects(:invoke).with(has_entry("query", "ice cream -#{Facet::GEOGRAPHIC}:[CALIFORNIA]"))
				Article.search "ice cream", :exclude_facets => {Facet::GEOGRAPHIC => "CALIFORNIA"}
			end
		end

		context ":fee" do
			should "send through as fee:Y if set to true" do
				Article.expects(:invoke).with(has_entry("query", "ice cream fee:Y"))
				Article.search "ice cream", :fee => true
			end
			
			should "send through as -fee:Y if set to false" do
				Article.expects(:invoke).with(has_entry("query", "ice cream -fee:Y"))
				Article.search "ice cream", :fee => false
			end
		end

		context ":fields" do
			context "for the :all argument" do
				should "pass all fields in a comma-delimited list" do
					Article.expects(:invoke).with(has_entry('fields', Article::ALL_FIELDS.join(',')))
					Article.search "FOO BAR", :fields => :all
				end
			end
			
			context "for the :none argument" do
				should "request a blank space for the fields argument"
				should "request the standard :facets if no :facets have been explicitly provided"
				should "request the given :facets field if provided"
			end
			
			context ":thumbnail" do
				should "accept the symbol version of the argument"
				should "accept the string version of the argument"
				should "request all the thumbnail image fields from the API"
			end
			
			context ":multimedia" do
				should "be implemented"
			end
			
			should "accept a single string as an argument" do
				Article.expects(:invoke).with(has_entry('fields', 'body'))
				Article.search "FOO BAR", :fields => 'body'
			end
			
			should "accept a single symbol as an argument" do
				Article.expects(:invoke).with(has_entry('fields', 'body'))
				Article.search "FOO BAR", :fields => :body
			end
			
			should "accept an array of strings and symbols" do
				Article.expects(:invoke).with(has_entry('fields', 'abstract,body'))
				Article.search "FOO BAR", :fields => [:abstract, 'body']
			end
			
			should "raise an ArgumentError otherwise" do
				assert_raise(ArgumentError) { Article.search :fields => 12 }
			end
		end

		context ":has_multimedia" do
			should "send through as related_multimedia:Y if set to true" do
				Article.expects(:invoke).with(has_entry("query", "ice cream related_multimedia:Y"))
				Article.search "ice cream", :has_multimedia => true
			end
			
			should "send through as -related_multimedia:Y if set to false" do
				Article.expects(:invoke).with(has_entry("query", "ice cream -related_multimedia:Y"))
				Article.search "ice cream", :has_multimedia => false
			end
		end

		context ":has_thumbnail" do
			should "send through as small_image:Y if set to true" do
				Article.expects(:invoke).with(has_entry("query", "ice cream small_image:Y"))
				Article.search "ice cream", :has_thumbnail => true
			end
			
			should "send through as -small_image:Y if set to false" do
				Article.expects(:invoke).with(has_entry("query", "ice cream -small_image:Y"))
				Article.search "ice cream", :has_thumbnail => false
			end
		end

		context ":offset" do
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
			
			should "raise an ArgumentError if the page is less than 1" do
				assert_raise(ArgumentError) { Article.search :page => 0 }
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

		Article::TEXT_FIELDS.each do |tf|
			context ":#{tf} parameter" do
				should "prefix each non-quoted term with the #{tf}: field identifier in the query to the API" do
					Article.expects(:invoke).with(has_entry("query", "#{tf}:ice #{tf}:cream"))
					Article.search tf.to_sym => 'ice cream'
				end
				
				should "prefix -terms (excluded terms) with -#{tf}:" do
					Article.expects(:invoke).with(has_entry("query", "#{tf}:ice -#{tf}:cream"))
					Article.search tf.to_sym => 'ice -cream'
				end
				
				should "put quoted terms behind the field spec" do
					Article.expects(:invoke).with(has_entry("query", "#{tf}:\"ice cream\" #{tf}:cone"))
					Article.search tf.to_sym => '"ice cream" cone'
				end
				
				should "handle complicated combinations of expressions" do
					Article.expects(:invoke).with(has_entry("query", "#{tf}:\"ice cream\" -#{tf}:cone #{tf}:\"waffle\""))
					Article.search tf.to_sym => '"ice cream" -cone "waffle"'
				end
			end
		end
		
		# context "query parameters" do
		# 	context "abstract" do
		# 		should "be prefixed with the abstract: field identifier in the query"
		# 		should "cast the argument to a string (will figure out processing later)"
		# 	end
		# 
		# 	context "author" do
		# 		should "be prefixed with the author: field identifier in the query"
		# 		should "cast the argument to a string (will figure out processing later)"
		# 	end
		# 
		# 	context "body" do
		# 		should "be prefixed with the body: field identifier in the query"
		# 		should "cast the argument to a string (will figure out processing later)"
		# 	end
		# 
		# 	context "byline" do
		# 		should "be prefixed with the body: field identifier in the query"
		# 		should "cast the argument to a string (will figure out processing later)"
		# 	end
		# end
	end

	context "Article.init_from_api" do
		setup do
			@article = Article.init_from_api(ARTICLE_API_HASH2)
		end

		Article::TEXT_FIELDS.each do |tf|
			context "@#{tf}" do
				should "read the value from the hash input" do
					hash = {}
					hash[tf] = "TEST TEXT"
					article = Article.init_from_api(hash)
					assert_equal "TEST TEXT", article.send(tf)
				end

				should "properly translate HTML entities back into characters" do
					article = Article.init_from_api(tf => '&#8220;Money for Nothing&#8221;')
					assert_equal "“Money for Nothing”", article.send(tf), article.inspect
				end

				should "only provide read-only access to the field" do
					article = Article.init_from_api(tf => "TEST TEXT")
					assert !article.respond_to?("#{tf}=")
				end

				should "return nil if the value is not provided in the hash" do
					article = Article.init_from_api({"foo" => "bar"})
					assert_nil article.send(tf)
				end
			end
		end

		Article::NUMERIC_FIELDS.each do |tf|
			context "@#{tf}" do
				should "read and coerce the string value from the hash input" do
					article = Article.init_from_api(tf => "23")
					assert_equal 23, article.send(tf)
				end

				should "only provide read-only access to the field" do
					article = Article.init_from_api(tf => "23")
					assert !article.respond_to?("#{tf}=")
				end

				should "return nil if the value is not provided in the hash" do
					article = Article.init_from_api({"foo" => "bar"})
					assert_nil article.send(tf)
				end	
			end				
		end
		
		# all the rest
		context "@fee" do
			setup do
				@article = Article.init_from_api(ARTICLE_API_HASH)
			end
			
			should "be true if returned as true from the API" do
				article = Article.init_from_api('fee' => true)
				assert_equal true, article.fee?
				assert_equal false, article.free?
			end
			
			should "default to false if not specified in the hash" do
				assert_equal false, @article.fee?
				assert_equal true, @article.free?
			end
		end
		
		context "@url" do
			setup do
				@article = Article.init_from_api(ARTICLE_API_HASH)
			end
			
			should "read the value from the hash" do
				assert_equal ARTICLE_API_HASH['url'], @article.url
			end
			
			should "return a String" do
				assert_kind_of(String, @article.url)
			end

			should "only provide read-only access to the field" do
				assert !@article.respond_to?("url=")
			end

			should "return nil if the value is not provided in the hash" do
				article = Article.init_from_api({"foo" => "bar"})
				assert_nil article.url
			end	
		end
		
		context "@page" do
			should "read the value from the page_facet field" do
				assert_equal ARTICLE_API_HASH2['page_facet'].to_i, @article.page
			end

			should "only provide read-only access to the field" do
				article = Article.new
				assert !article.respond_to?("page=")
			end

			should "return nil if the value is not provided in the hash" do
				article = Article.init_from_api({"foo" => "bar"})
				assert_nil article.page
			end
		end
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