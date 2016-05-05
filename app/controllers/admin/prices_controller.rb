class Admin::PricesController < AdminController
  include ProductLookup
  include ::Financials::Pricing

  before_action :ensure_child_units

  def index
    @price = @product.prices.build.decorate
    markets = @product.organization.all_markets
    @net_percents_by_market_id = ::Financials::Pricing.seller_net_percents_by_market(markets)
    @seller_cc_rate = ::Financials::Pricing.seller_cc_rate(current_market)
  end

  def create
    @price = @product.prices.create(price_params)
    if @price.persisted?
      redirect_to [:admin, @product, :prices], notice: "Successfully added a new price"
    else
      @price = @price.decorate
      markets = @product.organization.all_markets
      @net_percents_by_market_id = ::Financials::Pricing.seller_net_percents_by_market(markets)
      @seller_cc_rate = ::Financials::Pricing.seller_cc_rate(current_market)
      flash.now[:alert] = "Could not save price"
      render :index
    end
  end

  def update
    old_price = @product.prices.find(params[:id])
    params[:price] = params[:price][old_price.id.to_s]
    price = old_price.dup
    Price.soft_delete(old_price)
    price.save
    if price.update price_params
      respond_to do |format|
        format.html { redirect_to [:admin, @product, :prices], notice: "Successfully saved price" }
        format.js   do
          toggle = price.decorate
          @data = {
            message: "Successfully saved price",
            params: price_params.to_a,
            toggle: toggle.quick_info
          }
          render json: @data, status: 200
        end
      end
    else
      respond_to do |format|
        format.html do
          @price_with_errors = price
          @price = @product.prices.build.decorate
          markets = @product.organization.all_markets
          @net_percents_by_market_id = ::Financials::Pricing.seller_net_percents_by_market(markets)
          flash.now[:alert] = "Could not save price"
          render :index
        end
        format.js do
          @data = {
            errors:  price.errors.full_messages
          }
          render json: @data, status: 422
        end
      end
    end
  end

  def destroy
    removed = Price.soft_delete(Array.wrap(params[:id]))
    redirect_to [:admin, @product, :prices], notice: "Successfully removed price".pluralize(removed.size)
  end

  private

  def price_params
    params.require(:price).slice(:market_id, :organization_id, :min_quantity, :product_fee_pct, :sale_price).permit!
  end

  def query_params
    params.fetch(:query_params, {})
  end

  def ensure_child_units
    @child_units = []
    if @product
      @child_units << @product
      if @product && @product.general_product
        @child_units.concat(@product.general_product.product.visible.all
                              .reject { |sibling| sibling.id == @product.id }
                              .sort { |a, b| a.unit.plural <=> b.unit.plural })
      end
    end
  end
end
