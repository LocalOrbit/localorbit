class Admin::PricesController < AdminController
  include ProductLookup

  def index
    @price = @product.prices.build.decorate
  end

  def create
    @price = @product.prices.create(price_params)
    if @price.persisted?
      redirect_to [:admin, @product, :prices], notice: "Successfully added a new price"
    else
      @price = @price.decorate
      flash.now[:alert] = "Could not save price"
      render :index
    end
  end

  private

  def price_params
    params.require(:price).permit(:market_id, :organization_id, :min_quantity, :sale_price)
  end
end
