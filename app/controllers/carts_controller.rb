class CartsController < ApplicationController
  def update
    puts "This pry should happen"
    binding.pry
    puts "Session...."

    puts session[:product_id]
    puts session[:current_organization]

    item = current_cart.items.find_or_initialize_by(product_id: item_params[:product_id])
    item.quantity = item_params[:quantity]

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
