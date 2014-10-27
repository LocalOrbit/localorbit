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
    include_product_names = params[:include_product_names] || false
    context = GenerateTableTentsOrPosters.perform(order: order, type: type, include_product_names: include_product_names)
    if context.success?
      render text: context.pdf_result.data, content_type: "application/pdf"
    else
      flash[:alert] = "Couldn't generate #{params[:type]} document."
      redirect_to order_table_tents_and_posters_path(order_id:order.id, type: type)
    end
  end

  def show
  end

end
