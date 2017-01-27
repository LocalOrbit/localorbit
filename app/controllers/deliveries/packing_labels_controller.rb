class Deliveries::PackingLabelsController < ApplicationController


  # Arrive at index when user clicks "Lables" on their Upcoming Deliveries.
  # Triggers creation of a new Packing Labels printable PDF and redirects 
  # to the #show action where you wait for the generator to complete.
  def index
    product_only = params[:product_only]
    #delivery =  Delivery.find(params[:delivery_id])
    dt = params[:delivery_deliver_on].to_date
    dte = dt.strftime("%Y-%m-%d")

    printable = PackingLabelsPrintable.create!(user: current_user, deliver_on: dte)
    if Rails.env == "development" || current_market.product_label_format == 1 # Print zebra labels directly
      ProcessPackingLabelsPrintable.perform(
        packing_labels_printable_id: printable.id, 
        request: RequestUrlPresenter.new(request),
        product_labels_only: product_only,
        product_label_format: current_market.product_label_format,
        print_multiple_labels_per_item: current_market.print_multiple_labels_per_item,
        delivery_date: dte
      )
    else
      ProcessPackingLabelsPrintable.delay.perform(
        packing_labels_printable_id: printable.id, 
        request: RequestUrlPresenter.new(request),
        product_labels_only: product_only,
        product_label_format: current_market.product_label_format,
        print_multiple_labels_per_item: current_market.print_multiple_labels_per_item,
        delivery_date: dte
      )
    end
    track_event EventTracker::DownloadedPackingLabels.name
    redirect_to action: :show, deliver_on: dte, id: printable.id
  end

  def show
    @printable = PackingLabelsPrintable.for_user(current_user).find params[:id]
    @zpl_printer = current_market.zpl_printer

    respond_to do |format|
      format.html {}
      format.json do 
        output = if @printable.pdf then {pdf_url: @printable.pdf.remote_url} else {pdf_url: nil} end
        render json: output
      end
    end
  end

end
