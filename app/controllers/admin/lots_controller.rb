class Admin::LotsController < AdminController
  before_filter :find_product

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

  private

  def lot_params
    params.require(:lot).permit(:number, :good_from, :expires_at, :quantity)
  end

  def find_product
    @product = current_user.managed_products.find(params[:product_id])
  end
end
