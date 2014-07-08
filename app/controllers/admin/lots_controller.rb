class Admin::LotsController < AdminController
  include ProductLookup

  before_action :redirect_simple_inventory

  def index
    @lot = @product.lots.build
  end

  def create
    @lot = @product.lots.create(lot_params)
    if @lot.persisted?
      respond_to do |format|
        format.html { redirect_to [:admin, @product, :lots], notice: "Successfully added a new lot" }
        format.js   {
          @data = {
            message: "Successfully added a new lot",
            params: lot_params.to_a,
            toggle: @lot.product.available_inventory
          }
          render json: @data, status: 200
        }
      end
    else
      flash.now[:alert] = "Could not save lot"
      respond_to do |format|
        format.html { render :index }
        format.js   {
          @data = {
            errors: @lot.errors.full_messages
          }
          render json: @data, status: 422
        }
      end
    end
  end

  def update
    lot = @product.lots.find(params[:id])
    params[:lot] = params[:lot][lot.id.to_s]
    if lot.update lot_params
      respond_to do |format|
        format.html { redirect_to [:admin, @product, :lots], notice: "Successfully saved lot" }
        format.js {
          @data = {
            message: "Successfully added a new lot",
            params: lot_params.to_a,
            toggle: lot.product.available_inventory
          }
          render json: @data, status: 200
        }
      end
    else
      @lot_with_errors = lot
      @lot = @product.lots.build
      respond_to do |format|
        format.html {
          flash.now[:alert] = "Could not save lot"
          render :index
        }
        format.js {
          @data = {
            errors: @lot.errors.full_messages
          }
          render json: @data, status: 422
        }
      end
    end
  end

  private

  def lot_params
    params.require(:lot).permit(:number, :good_from, :expires_at, :quantity)
  end

  def query_params
    params.fetch(:query_params, {})
  end

  def redirect_simple_inventory
    redirect_to [:admin, @product] if @product.use_simple_inventory?
  end
end
