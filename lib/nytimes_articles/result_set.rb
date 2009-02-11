require 'rubygems'
require 'forwardable'

module Nytimes
	module Articles
		class ResultSet < Base
			extend Forwardable
			attr_reader :offset, :total_results, :results
			
			BATCH_SIZE = 10
			
			def_delegators :@results, :&, :*, :+, :-, :[], :at, :collect, :compact, :each, :each_index, :empty?, :fetch, :first, :include?, :index, :last, :length, :map, :nitems, :reject, :reverse, :reverse_each, :rindex, :select, :size, :slice  
			
			def initialize(params)
				@offset = params[:offset]
				@total_results = params[:total_results]
				@results = params[:results]
			end
			
			def page_number
				return 0 if @total_results == 0
				@offset + 1
			end
			
			def total_pages
				return 0 if @total_results == 0
				(@total_results.to_f / BATCH_SIZE).ceil
			end
			
			def self.init_from_api(api_hash)
				self.new(:offset => integer_field(api_hash['offset']),
								 :total_results => integer_field(api_hash['total']),
								 :results => api_hash['results'].map {|r| Article.init_from_api(r)})
			end
		end
	end
end