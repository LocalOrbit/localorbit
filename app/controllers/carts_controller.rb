class CartsController < ApplicationController
  before_action :require_current_organization
  before_action :require_organization_location
  before_action :require_current_delivery
  before_action :require_cart
  before_action :hide_admin_navigation

  def show
    @grouped_items = current_cart.items.for_checkout
  end

  def update
    product = Product.find(item_params[:product_id])

    @item = current_cart.items.find_or_initialize_by(product_id: item_params[:product_id])
    @item.quantity = item_params[:quantity]
    @item.product = product

    if @item.quantity > product.available_inventory
      @error = "Quantity available for purchase: #{product.available_inventory}"
      @item.quantity = product.available_inventory
    end

    if !@item.save
      render status: :unprocessable_entity, json: {error: "Could not add item!"}
    end
  end

  private

  def item_params
    params.permit(:product_id, :quantity)
  end
end
