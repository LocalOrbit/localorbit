class Deliveries::PackingLabelsController < ApplicationController

  def create

    delivery =  Delivery.find(params[:delivery_id])
    printable = PackingLabelsPrintable.create!(user: current_user, delivery: delivery)
    ProcessPackingLabelsPrintable.delay.perform(
      packing_labels_printable_id: printable.id, 
      request: RequestUrlPresenter.new(request)
    )
    redirect_to action: :show, delivery_id: delivery.id, id: printable.id
  end

  def show
    # PackingLabelsPrintable.for_user(current_user).find(params[:id])
    # render text: context.pdf_result.data, content_type: "application/pdf"
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
