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

  def update
    price = @product.prices.find(params[:id])
    params[:price] = params[:price][price.id.to_s]
    if price.update price_params
      redirect_to [:admin, @product, :prices], notice: "Successfully saved price"
    else
      @price_with_errors = price
      @price = @product.prices.build.decorate
      flash.now[:alert] = "Could not save price"
      render :index
    end
  end

  def destroy
    Price.destroy(params[:id])
    redirect_to [:admin, @product, :prices], notice: "Successfully removed price"
  end

  private

  def price_params
    params.require(:price).permit(:market_id, :organization_id, :min_quantity, :sale_price)
  end
end
