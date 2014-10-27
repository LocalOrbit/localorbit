class TableTentsAndPostersController < ApplicationController
  def index
    if params[:type] == "poster"
      @printables = 'posters'
      @title = 'Posters (8.5" x 11")'
    else
      @printables = 'table tents'
      @title = 'Table Tents (4" x 6")'
    end
  end

  def create
    order = Order.orders_for_buyer(current_user).find(params[:order_id])
    type = params[:type]
    include_product_names = params[:include_product_names]
    context = GenerateTableTentsOrPosters.perform(order: order, type: type, include_product_names: include_product_names)
    binding.pry
    if context.success?
      render text: context.pdf_result.data, content_type: "application/pdf"
    else
      flash[:alert] = "Couldn't generate #{params[:type]} document."
      redirect_to :index
    end
  end

  def show
  end

end