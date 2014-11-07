class GeneratePackingLabels
  def perform
    delivery, request = require_in_context(:delivery, :request)

    # order_infos = GeneratePackingLabels.make_order_infos(delivery)
    # labels = GeneratePackingLabels.make_labels(order_infos)
    # pages = GeneratePackingLabels.make_pages(labels)
    #
    # pdf_context = GeneratePdf.perform(
    #   request: RequestUrlPresenter.new(request),
    #   template: "avery_labels/labels", 
    #   pdf_size: { page_size: "letter" },
    #   params: {
    #     pages: pages
    #   })
    #
    # context[:pdf_result] = pdf_context.pdf_result
  end

  # def self.make_order_infos(delivery)
  #   raise "TODO"
  # end
  #
  # def self.make_labels(order_infos)
  #   raise "TODO"
  # end
  #
  # def self.make_pages(labels)
  #   raise "TODO"
  # end
  #
end
