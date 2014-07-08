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
      respond_to do |format|
        format.html { redirect_to [:admin, @product, :prices], notice: "Successfully saved price" }
        format.js   {
          toggle = price.decorate
          @data = {
            message: "Successfully saved price",
            params: price_params.to_a,
            toggle: toggle.quick_info
          }
          render json: @data, status: 200
        }
      end
    else
      respond_to do |format|
        format.html do
          @price_with_errors = price
          @price = @product.prices.build.decorate
          flash.now[:alert] = "Could not save price"
          render :index
        end
        format.js {
          @data = {
            errors:  price.errors.full_messages
          }
          render json: @data, status: 422
        }
      end
    end
  end

  def destroy
    removed = Price.destroy(Array.wrap(params[:id]))
    redirect_to [:admin, @product, :prices], notice: "Successfully removed price".pluralize(removed.size)
  end

  private

  def price_params
    params.require(:price).slice(:market_id, :organization_id, :min_quantity, :sale_price).permit!
  end

  def query_params
    params.fetch(:query_params, {})
  end
end
