module Admin
  class DiscountsController < AdminController
    include StickyFilters

    def index
      @query_params = sticky_parameters(request.query_parameters)
      base_scope = Discount.all

      @discounts = base_scope
      @markets = base_scope.map(&:market).uniq
      @q = base_scope.search(@query_params["q"])
    end
  end
end
