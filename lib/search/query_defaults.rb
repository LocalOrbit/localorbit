module Search
  class QueryDefaults
    attr_reader :query
    def initialize(q, date_search_attr)
      q = (q || {}).with_indifferent_access.deep_dup
      query = {}.with_indifferent_access

      query["#{date_search_attr}_date_gteq"] = q.delete("#{date_search_attr}_date_gteq") || 30.days.ago.to_date.to_s
      query["#{date_search_attr}_date_lteq"] = q.delete("#{date_search_attr}_date_lteq") || Date.today.to_s
      query["order_market_id_eq"] = q.delete("order_market_id_eq") unless q["order_market_id_eq"].nil?

      # HACK:
      # Due to order of association loading with ransack, date filters for order
      # items need to be loaded prior to other filters. To do this, we set them
      # as the first keys in the query hash.
      # TODO: Find a better way to fix this.
      @query = query.merge(q)
    end
  end
end
