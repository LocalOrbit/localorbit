class TableTentsAndPostersController < ApplicationController
  DefaultPrintableType = 'table tent'

  def index
    @type = params[:type]
    @printables = printables_name_for_type(params[:type])
    @title = title_for_type(params[:type])
  end

  def create
    order = Order.orders_for_buyer(current_user).find(params[:order_id])
    type = params[:type] || DefaultPrintableType
    include_product_names = params[:include_product_names] || false
    request_url_presenter = RequestUrlPresenter.new(request)
    intercom_event_type = if type == "poster" then EventTracker::DownloadedPosters.name else EventTracker::DownloadedTableTents.name end

    order_printable = OrderPrintable.create!(order: order, printable_type: type, include_product_names: include_product_names)

    ProcessOrderPrintable.delay.perform(order_printable_id: order_printable.id, request: RequestUrlPresenter.new(request))

    track_event intercom_event_type, order: { url: admin_order_url(id: order.id), value: order.order_number }
    redirect_to order_table_tents_and_poster_path(order_id:order.id, id: order_printable.id)
  end

  def show
    printable = OrderPrintable.find params[:id]
    respond_to do |format|
      format.html do
        @printables = printables_name_for_type(printable.printable_type)
      end
      format.json do 
        output = if printable.pdf then {pdf_url: printable.pdf.remote_url} else {pdf_url: nil} end
        render json: output
      end
    end
  end

  private

  def printables_name_for_type(type)
    if type == "poster"
      'posters'
    else
      'table tents'
    end
  end

  def title_for_type(type)
    if @type == "poster"
      'Posters (8.5" x 11")'
    else
      'Table Tents (4" x 6")'
    end
  end

end
