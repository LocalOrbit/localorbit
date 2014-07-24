module Admin
  class DiscountsController < AdminController
    include StickyFilters

    before_action :require_admin_or_market_manager
    before_action :find_select_data, only: [:new, :create, :show, :update]

    def index
      @query_params = sticky_parameters(request.query_parameters)

      base_scope = Discount.visible

      @markets   = base_scope.map(&:market).uniq
      @q         = base_scope.search(@query_params["q"])
      @discounts = @q.result.page(params[:page]).per(@query_params[:per_page])
    end

    def new
      @discount = Discount.new
    end

    def create
      @discount = Discount.new(discount_params)
      if @discount.save
        redirect_to admin_discounts_path, notice: 'Successfully created discount.'
      else
        flash.now[:alert] = "Error creating discount."
        render "new"
      end
    end

    def show
      @discount = Discount.find(params[:id])
    end

    def update
      @discount = Discount.find(params[:id])
      if @discount.update(discount_params)
        redirect_to admin_discounts_path, notice: 'Successfully updated discount.'
      else
        flash.now[:alert] = "Error updating discount."
        render "show"
      end
    end

    def destroy
      if Discount.soft_delete(params[:id])
        redirect_to admin_discounts_path, notice: 'Successfully removed discount.'
      else
        redirect_to admin_discounts_path, alert: 'Unable to remove discount.'
      end
    end

    private

    def discount_params
      params.require(:discount).permit(
        :name,
        :code,
        :market_id,
        :start_date,
        :end_date,
        :type,
        :discount,
        :product_id,
        :buyer_organization_id,
        :seller_organization_id,
        :minimum_order_total,
        :maximum_order_total,
        :maximum_uses,
        :maximum_organization_uses
      )
    end

    def find_select_data
      @markets = if current_user.admin?
        Market.all
      else
        current_user.managed_markets
      end.order(:name)

      org_ids = @markets.map {|m| m.organization_ids }.flatten
      @products = Product.where(organization_id: org_ids).order(:name)

      @organizations = Organization.
          joins(market_organizations: :market).
          where(markets: {id: current_user.managed_market_ids}, market_organizations: {deleted_at: nil}).
          distinct("organization.id").
          order(:name)
    end
  end
end
