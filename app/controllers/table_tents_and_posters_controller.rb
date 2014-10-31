class TableTentsAndPostersController < ApplicationController
  DefaultPrintableType = 'table tent'

  def index
    @type = params[:type]
    if @type == "poster"
      @printables = 'posters'
      @title = 'Posters (8.5" x 11")'
    else
      @printables = 'table tents'
      @title = 'Table Tents (4" x 6")'
    end
  end

  def create
    order = Order.orders_for_buyer(current_user).find(params[:order_id])
    type = params[:type] || DefaultPrintableType
    include_product_names = params[:include_product_names] || false
    request_url_presenter = RequestUrlPresenter.new(request)
    context = GenerateTableTentsOrPosters.perform(order: order, type: type, include_product_names: include_product_names, request: request_url_presenter)
    if context.success?
      render text: context.pdf_result.data, content_type: "application/pdf"
    else
      flash[:alert] = "Couldn't generate #{type} document."
      redirect_to order_table_tents_and_posters_path(order_id:order.id, type: type)
    end
  end

  def show
    respond_to do |format|
      format.html {}
      format.json do 
        render json: {hi:"there"} 
      end
    end
  end

end
