module Search
  class QueryDefaults
    attr_reader :query
    def initialize(query, date_search_attr)
      @query = query || {}

      @query["#{date_search_attr}_date_gteq"] ||= 1.month.ago.to_date.to_s
      @query["#{date_search_attr}_date_lteq"] ||= 1.day.from_now.to_date.to_s
    end
  end
end
