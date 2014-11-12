class ProcessPackingLabelsPrintable
  include Interactor

  def perform
    packing_labels_printable, request = require_in_context(:packing_labels_printable, :request)
    delivery_printable = PackingLabelsPrintable.find packing_labels_printable
    context = PackingLabels::Generator.generate(delivery: delivery_printable.delivery, request: request)
    delivery_printable.pdf = context.pdf_result.data
    delivery_printable.pdf.name = "delivery_labels.pdf"
    delivery_printable.save
  end
end
