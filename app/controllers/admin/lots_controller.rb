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
        format.js   { redirect_to admin_products_path(query_params), notice: "Successfully added a new lot" }
      end
    else
      flash.now[:alert] = "Could not save lot"
      respond_to do |format|
        format.html { render :index }
        format.js   { redirect_to admin_products_path(query_params), alert: "Could not save lot" }
      end
    end
  end

  def update
    lot = @product.lots.find(params[:id])
    params[:lot] = params[:lot][lot.id.to_s]
    if lot.update lot_params
      redirect_to [:admin, @product, :lots], notice: "Successfully saved lot"
    else
      @lot_with_errors = lot
      @lot = @product.lots.build
      flash.now[:alert] = "Could not save lot"
      render :index
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
