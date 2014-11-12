class ProcessPackingLabelsPrintable
  include Interactor

  def perform
    packing_labels_printable, request = require_in_context(:packing_labels_printable_id, :request)
    delivery_printable = PackingLabelsPrintable.find packing_labels_printable_id
    pdf_result = PackingLabels::Generator.generate(delivery: delivery_printable.delivery, request: request)
    delivery_printable.pdf = pdf_result.data
    delivery_printable.pdf.name = "delivery_labels.pdf"
    delivery_printable.save!
  end
end
