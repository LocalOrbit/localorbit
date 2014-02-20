class Admin::LotsController < AdminController
  before_action :find_product
  before_action :redirect_simple_inventory

  def index
    @lot = @product.lots.build
  end

  def create
    @lot = @product.lots.create(lot_params)
    if @lot.persisted?
      redirect_to [:admin, @product, :lots], notice: "Successfully added a new lot"
    else
      flash.now[:alert] = "Could not save lot"
      render :index
    end
  end

  def update
    @lot = @product.lots.find(params[:id])
    params[:lot] = params[:lot][@lot.id.to_s]
    if @lot.update lot_params
      redirect_to [:admin, @product, :lots], notice: "Successfully saved lot"
    else
      flash.now[:alert] = "Could not save lot"
      render :index
    end
  end

  private

  def lot_params
    params.require(:lot).permit(:number, :good_from, :expires_at, :quantity)
  end

  def find_product
    @product = current_user.managed_products.find(params[:product_id])
  end

  def redirect_simple_inventory
    if @product.use_simple_inventory?
      redirect_to [:admin, @product]
    end
  end
end
