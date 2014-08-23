class Admin::LotsController < AdminController
  include ProductLookup

  before_action :redirect_simple_inventory

  def index
    @lot = @product.lots.build
  end

  def create
    @lot = @product.lots.create(lot_params)

    flash.now[:alert] = "Could not save lot" unless @lot.persisted?
    respond_to do |format|
      format.html { html_for_action(@lot.persisted?, "Successfully added a new lot") }
      format.js   { json_for_action(@lot.persisted?, "Successfully added a new lot") }
    end
  end

  def update
    @lot = @product.lots.find(params[:id])
    params[:lot] = params[:lot][@lot.id.to_s]

    updated = @lot.update(lot_params)

    if !updated
      @lot_with_errors = @lot
      @lot = @product.lots.build
    end

    flash.now[:alert] = "Could not save lot" unless updated
    respond_to do |format|
      format.html { html_for_action(updated, "Successfully saved lot") }
      format.js   { json_for_action(updated, "Successfully saved lot")}
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

  def html_for_action(updated, message)
    if updated
      redirect_to [:admin, @product, :lots], notice: message
    else
      render :index
    end
  end

  def json_for_action(updated, message)
    @data = if updated
      {
        message: message,
        params: @lot_params.to_a,
        toggle: @lot.product.available_inventory
      }
    else
      {
        errors: @lot.errors.full_messages
      }
    end

    status_code = updated ? 200 : 422
    render json: @data, status: status_code
  end
end
