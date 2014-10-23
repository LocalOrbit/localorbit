module Dev
  class PdfController < ApplicationController
    layout false

    def index
    end

    def fuh
      render text: "<h1>fuh</h1>", type: "text/html"
    end

    def ttp
      if params[:order_id]
      order_id = params.require(:order_id)

      order = Order.find(order_id)
      type = params[:type] || "table tent"
      include_product_names = params[:include_product_names] == "true"
      req = Struct.new(:base_url).new(request.base_url.sub("3000", "3500"))

      context = GenerateTableTentsOrPosters.perform(
        order: order,
        type: type,
        include_product_names: include_product_names,
        request: req
      )

      render text: context.pdf_result.data, content_type: "application/pdf"
      else
        render
      end
    end

  end
end
