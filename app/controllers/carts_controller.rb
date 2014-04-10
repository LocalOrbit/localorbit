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
    delivery_date = current_delivery.deliver_on

    @item = current_cart.items.find_or_initialize_by(product_id: item_params[:product_id])

    if item_params[:quantity].to_i > 0
      @item.quantity = item_params[:quantity]
      @item.product = product

      if @item.quantity && @item.quantity > 0 && @item.quantity > product.available_inventory(delivery_date)
        @error = "Quantity available for purchase: #{product.available_inventory(delivery_date)}"
        @item.quantity = product.available_inventory(delivery_date)
      end

      if !@item.save
        @error = @item.errors.full_messages.join(". ")
      end
    else
      @item.update(quantity: 0)
      @item.destroy
    end
  end

  def destroy
    current_cart.destroy
    session.delete(:cart_id)
    redirect_to [:products]
  end

  private

  def item_params
    params.permit(:product_id, :quantity)
  end
end
