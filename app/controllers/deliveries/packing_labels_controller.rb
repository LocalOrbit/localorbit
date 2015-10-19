class Deliveries::PackingLabelsController < ApplicationController


  # Arrive at index when user clicks "Lables" on their Upcoming Deliveries.
  # Triggers creation of a new Packing Labels printable PDF and redirects 
  # to the #show action where you wait for the generator to complete.
  def index
    product_only = params[:product_only]
    delivery =  Delivery.find(params[:delivery_id])

    printable = PackingLabelsPrintable.create!(user: current_user, delivery: delivery)
    if Rails.env == "development"
      ProcessPackingLabelsPrintable.perform(
        packing_labels_printable_id: printable.id, 
        request: RequestUrlPresenter.new(request),
        product_labels_only: product_only
      )
    else
      ProcessPackingLabelsPrintable.delay.perform(
        packing_labels_printable_id: printable.id, 
        request: RequestUrlPresenter.new(request),
        product_labels_only: product_only
      )
    end
    track_event EventTracker::DownloadedPackingLabels.name
    redirect_to action: :show, delivery_id: delivery.id, id: printable.id
  end

  def show
    printable = PackingLabelsPrintable.for_user(current_user).find params[:id]
    respond_to do |format|
      format.html {}
      format.json do 
        output = if printable.pdf then {pdf_url: printable.pdf.remote_url} else {pdf_url: nil} end
        render json: output
      end
    end
  end

end
