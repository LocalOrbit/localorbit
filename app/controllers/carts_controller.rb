class CartsController < ApplicationController
  def update
    product = Product.find(item_params[:product_id])

    item = current_cart.items.find_or_initialize_by(product_id: item_params[:product_id])
    item.quantity = item_params[:quantity]
    item.product = product

    if item.save
      render json: item
    else
      render status: :unprocessable_entity, json: {error: "Could not add item!"}
    end
  end

  private

  def item_params
    params.permit(:product_id, :quantity)
  end
end
