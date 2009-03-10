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
				should "send the :before value through as a end_date" do
					t = Time.now
					Article.expects(:invoke).with(has_entry('end_date', t.strftime("%Y%m%d")))
					Article.search :before => t
				end
				
				should "not send through :before as an argument to the API" do
					t = Time.now
					Article.expects(:invoke).with(Not(has_key('before')))
					Article.search :before => t
				end
				
				should "raise an ArgumentError if the before_date is NOT a string and does not respond_to strftime" do
					assert_raise(ArgumentError) { Article.search :before => 23 }
				end
				
				should "add a begin_date in 1980 if no :since or :begin_date argument is provided" do
					Article.expects(:invoke).with(has_entry('begin_date', Article::EARLIEST_BEGIN_DATE))
					Article.search :before => Time.now
				end
				
				should "not automatically add a begin_date is there is a :since argument" do
					since = Time.now - 12000
					Article.expects(:invoke).with(has_entry('begin_date', since.strftime("%Y%m%d")))
					Article.search :before => Time.now, :since => since
				end
				
				should "not automatically add a begin_date if there is a :begin_date argument already" do
					since = Time.now - 12000
					Article.expects(:invoke).with(has_entry('begin_date', since.strftime("%Y%m%d")))
					Article.search :before => Time.now, :begin_date => since
				end
				
				should "raise an ArgumentError if there is also an :end_date argument" do
					assert_raise(ArgumentError) { Article.search :before => Time.now, :end_date => Time.now }
				end
			end

			context ":since" do
				should "send the :since value through as a begin_date" do
					t = Time.now - 1200
					Article.expects(:invoke).with(has_entry('begin_date', t.strftime("%Y%m%d")))
					Article.search :since => t
				end
				
				should "not send through :since as an argument to the API" do
					t = Time.now
					Article.expects(:invoke).with(Not(has_key('since')))
					Article.search :since => t
				end
				
				should "raise an ArgumentError if the before_date is NOT a string and does not respond_to strftime" do
					assert_raise(ArgumentError) { Article.search :since => 23 }
				end
				
				# This is to fix an error where the begin and end date are the same
				should "add a end_date of tomorrow if no :before or :end_date argument is provided" do
					Article.expects(:invoke).with(has_entry('end_date', (Date.today + 1).strftime("%Y%m%d")))
					Article.search :since => Date.today
				end
				
				should "not automatically add a end_date is there is a :before argument" do
					since = '19990101'
					Article.expects(:invoke).with(has_entry('end_date', '20030101'))
					Article.search :before => '20030101', :since => since
				end
				
				should "not automatically add a end_date if there is a :end_date argument already" do
					since = '19990101'
					Article.expects(:invoke).with(has_entry('end_date', '20030101'))
					Article.search :end_date => '20030101', :since => since
				end
				
				should "raise an ArgumentError if there is also an :begin_date argument" do
					assert_raise(ArgumentError) { Article.search :since => Time.now, :begin_date => Time.now }
				end
			end			
		end

		context "facets" do
			should "accept a single string" do
				Article.expects(:invoke).with(has_entry("facets", Facet::DATE))
				Article.search "FOO BAR", :facets => Facet::DATE
			end

			should "accept an array of strings" do
				Article.expects(:invoke).with(has_entry("facets", [Facet::DATE, Facet::GEO].join(',')))
				Article.search "FOO BAR", :facets => [Facet::DATE, Facet::GEO]
			end
		end
		
		context "only_facets" do
			should "accept a String" do
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEO}:[CALIFORNIA]"))
				Article.search :only_facets => "#{Facet::GEO}:[CALIFORNIA]"
			end
			
			should "accept a single hash value Facet string to a term" do
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEO}:[CALIFORNIA]"))
				Article.search :only_facets => {Facet::GEO => 'CALIFORNIA'}
			end
			
			should "accept an Facet string hashed to an array terms" do
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEO}:[CALIFORNIA] #{Facet::GEO}:[GREAT BRITAIN]"))
				Article.search :only_facets => {Facet::GEO => ['CALIFORNIA', 'GREAT BRITAIN']}
			end
			
			should "accept a single Facet object" do
				f = Facet.new(Facet::GEO, 'CALIFORNIA', 2394)
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEO}:[CALIFORNIA]"))
				Article.search :only_facets => f
			end
			
			should "accept an array of Facet objects" do
				f = Facet.new(Facet::GEO, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::NYTD_ORGANIZATION, 'University Of California', 12)
				
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEO}:[CALIFORNIA] #{Facet::NYTD_ORGANIZATION}:[University Of California]"))
				Article.search :only_facets => [f, f2]
			end
			
			should "merge multiple Facets objects in the array of the same type into one array" do
				f = Facet.new(Facet::GEO, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::GEO, 'IOWA', 12)
				
				Article.expects(:invoke).with(has_entry("query", "#{Facet::GEO}:[CALIFORNIA] #{Facet::GEO}:[IOWA]"))
				Article.search :only_facets => [f, f2]
			end
			
			should "not stomp on an existing query string" do
				Article.expects(:invoke).with(has_entry("query", "ice cream #{Facet::GEO}:[CALIFORNIA]"))
				Article.search "ice cream", :only_facets => {Facet::GEO => "CALIFORNIA"}
			end
		end

		context "except_facets" do
			should "accept a String" do
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEO}:[CALIFORNIA]"))
				Article.search :except_facets => "-#{Facet::GEO}:[CALIFORNIA]"
			end
			
			should "accept a single hash value Facet string to a term" do
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEO}:[CALIFORNIA]"))
				Article.search :except_facets => {Facet::GEO => 'CALIFORNIA'}
			end
			
			should "accept an Facet string hashed to an array terms" do
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEO}:[CALIFORNIA] -#{Facet::GEO}:[GREAT BRITAIN]"))
				Article.search :except_facets => {Facet::GEO => ['CALIFORNIA', 'GREAT BRITAIN']}
			end
			
			should "accept a single Facet object" do
				f = Facet.new(Facet::GEO, 'CALIFORNIA', 2394)
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEO}:[CALIFORNIA]"))
				Article.search :except_facets => f
			end
			
			should "accept an array of Facet objects" do
				f = Facet.new(Facet::GEO, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::NYTD_ORGANIZATION, 'University Of California', 12)
				
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEO}:[CALIFORNIA] -#{Facet::NYTD_ORGANIZATION}:[University Of California]"))
				Article.search :except_facets => [f, f2]
			end
			
			should "merge multiple Facets objects in the array of the same type into one array" do
				f = Facet.new(Facet::GEO, 'CALIFORNIA', 2394)
				f2 = Facet.new(Facet::GEO, 'IOWA', 12)
				
				Article.expects(:invoke).with(has_entry("query", "-#{Facet::GEO}:[CALIFORNIA] -#{Facet::GEO}:[IOWA]"))
				Article.search :except_facets => [f, f2]
			end
			
			should "not stomp on an existing query string" do
				Article.expects(:invoke).with(has_entry("query", "ice cream -#{Facet::GEO}:[CALIFORNIA]"))
				Article.search "ice cream", :except_facets => {Facet::GEO => "CALIFORNIA"}
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
				should "request a blank space for the fields argument" do
					Article.expects(:invoke).with(has_entry('fields', ' '))
					Article.search "FOO BAR", :fields => :none
				end
				
				should "request the standard :facets if no :facets have been explicitly provided" do
					Article.expects(:invoke).with(has_entry('facets', Facet::DEFAULT_RETURN_FACETS.join(',')))
					Article.search "FOO BAR", :fields => :none	
				end
				
				should "request the given :facets field if provided" do
					Article.expects(:invoke).with(has_entry('facets', "#{Facet::GEO}"))
					Article.search "FOO BAR", :fields => :none, :facets => Facet::GEO
				end
			end
			
			context ":thumbnail" do
				should "accept the symbol version of the argument" do
					Article.expects(:invoke).with(has_entry('fields', Article::IMAGE_FIELDS.join(',')))
					Article.search "FOO BAR", :fields => :thumbnail
				end
				
				should "accept the string version of the argument" do
					Article.expects(:invoke).with(has_entry('fields', Article::IMAGE_FIELDS.join(',')))
					Article.search "FOO BAR", :fields => 'thumbnail'
				end				
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
			
			should "be true if returned as Y from the API" do
				article = Article.init_from_api('fee' => 'Y')
				assert_equal true, article.fee?
				assert_equal false, article.free?
			end
			
			should "default to false if not specified in the hash" do
				assert_equal false, @article.fee?
				assert_equal true, @article.free?
			end
			
			should "default to false if returned as N from the API" do
				article = Article.init_from_api('fee' => 'N')
				assert_equal false, article.fee?
				assert_equal true, article.free?
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
		
		context "@thumbnail" do
			should "assign nil to thumbnail otherwise" do
				article = Article.init_from_api({"foo" => "bar"})
				assert_nil article.thumbnail
			end

			should "create a thumbnail object if a small_image_url is part of the return hash" do
				article = Article.init_from_api(ARTICLE_API_HASH2)
				thumbnail = article.thumbnail
				assert_not_nil thumbnail
				assert_kind_of Thumbnail, thumbnail
				assert_equal ARTICLE_API_HASH2['small_image_url'], thumbnail.url
				assert_equal ARTICLE_API_HASH2['small_image_width'].to_i, thumbnail.width
				assert_equal ARTICLE_API_HASH2['small_image_height'].to_i, thumbnail.height
			end
		end
		
		context "array facets" do
			should "have some tests for array facets"
		end
	end
end
