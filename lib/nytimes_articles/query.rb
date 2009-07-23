require 'digest'

module Nytimes
	module Articles
	  ##
	  # The Query class represents a single query to the Article Search API.  Supports
	  # all of the named parameters to Article.search as accessor methods.
	  #
	  class Query
      FIELDS = [:only_facets, :except_facets, :begin_date, :end_date, :since, 
	              :before, :fee, :has_thumbnail, :facets, :fields, :query, :offset] + Article::TEXT_FIELDS.map{|f| f.to_sym}
      FIELDS.each {|f| attr_accessor f}
      
      # Produce a hash which uniquely identifies this query
      def hash
        strs = FIELDS.collect {|f| "#{f}:#{send(f).inspect}"}
        Digest::SHA256.hexdigest(strs.join(' '))
      end
      
      # Perform this query.  Returns result of Article.search
      def perform
        params = {}
        FIELDS.each {|f| params[f] = send(f) unless send(f).nil?}
        Article.search(params)
      end
    end
  end
end