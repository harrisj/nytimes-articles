require 'rubygems'
require 'forwardable'

module Nytimes
	module Articles
		##
		# The ResultSet is returned by Article#search and contains an array of up to 10 results out of the total matches. For your convenience, this
		# object provides a selection of array methods on the underlying collection of articles.
		class ResultSet < Base
			extend Forwardable

			##
			# The offset of the result_set. Note that this is essentially the ordinal position of the batch among all results. First 10 results are offset
			# 0, the next 10 are offset 1, etc.
			attr_reader :offset
			
			##
			# The total results that matched the query.
			attr_reader :total_results
			
			##
			# The results array of articles returned. Note that if you call Articles#find with :fields => :none, this will return nil even if 
			# there are matching results.
			attr_reader :results
			
			##
			# If you have specified a list of <tt>:facets</tt> for Article#search, they will be returned in a hash keyed by the facet name here.
			attr_reader :facets
			
			BATCH_SIZE = 10
			
			def_delegators :@results, :&, :*, :+, :-, :[], :at, :collect, :compact, :each, :each_index, :empty?, :fetch, :first, :include?, :index, :last, :length, :map, :nitems, :reject, :reverse, :reverse_each, :rindex, :select, :size, :slice  
			
			def initialize(params)
				@offset = params[:offset]
				@total_results = params[:total_results]
				@results = params[:results]
				@facets = params[:facets]
			end
			
			##
			# For your convenience, the page_number method is an alternate version of #offset that counts up from 1.
			def page_number
				return 0 if @total_results == 0
				@offset + 1
			end
			
			##
			# Calculates the total number of pages in the results based on the standard batch size and total results.
			def total_pages
				return 0 if @total_results == 0
				(@total_results.to_f / BATCH_SIZE).ceil
			end
			
			##
			# Used to initialize a new result_set from Article#search.
			def self.init_from_api(api_hash)
				self.new(:offset => integer_field(api_hash['offset']),
								 :total_results => integer_field(api_hash['total']),
								 :results => api_hash['results'].map {|r| Article.init_from_api(r)},
								 :facets => Facet.init_from_api(api_hash['facets'])
								)
			end
		end
	end
end