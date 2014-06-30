module Search
  class QueryDefaults
    attr_reader :query
    def initialize(query, date_search_attr)
      @query = query || {}

      @query["#{date_search_attr}_date_gteq"] ||= 30.days.ago.to_date.to_s
      @query["#{date_search_attr}_date_lteq"] ||= Date.today.to_s
    end
  end
end
