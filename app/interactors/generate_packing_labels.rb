class GeneratePackingLabels
  include Interactor
  OrderTemplate = "avery_labels/order"
  ProductTemplate = "avery_labels/vertical_product"

  def perform
    delivery, request = require_in_context(:delivery, :request)

    order_infos = PackingLabels::OrderInfo.make_order_infos(delivery)
    labels = PackingLabels::Label.make_labels(order_infos)
    pages = PackingLabels::Page.make_pages(labels)

    pdf_context = GeneratePdf.perform(
      request: request,
      template: "avery_labels/labels",
      pdf_size: { page_size: "letter" },
      params: {
        pages: pages
      })

    context[:pdf_result] = pdf_context.pdf_result
  end


end
