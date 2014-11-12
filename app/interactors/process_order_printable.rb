class ProcessOrderPrintable
  include Interactor

  def perform
    order_printable_id, request = require_in_context(:order_printable_id, :request)
    order_printable = OrderPrintable.find order_printable_id
    context = GenerateTableTentsOrPosters.perform(order: order_printable.order, type: order_printable.printable_type, include_product_names: order_printable.include_product_names, request: request)
    order_printable.pdf = context.pdf_result.data
    order_printable.pdf.name = "#{order_printable.printable_type.gsub(/\s+/,'_')}.pdf"
    order_printable.save!
  end
end
