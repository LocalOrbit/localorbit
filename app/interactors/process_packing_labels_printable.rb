class ProcessPackingLabelsPrintable
  include Interactor

  def perform
    packing_labels_printable, request, product_labels_only = require_in_context(:packing_labels_printable_id, :request, :product_labels_only)
    delivery_printable = PackingLabelsPrintable.find packing_labels_printable_id
    delivery = delivery_printable.delivery
    user = delivery_printable.user
    orders = delivery.orders.for_seller(user).sort_by(&:id)
    seller_orders = orders.map do |o| SellerOrder.new(o,user) end

    # pdf_result = PackingLabels::Generator.generate(orders: orders, request: request)
    pdf_result = PackingLabels::Generator.generate(orders: seller_orders, request: request, product_labels_only: product_labels_only)
    delivery_printable.pdf = pdf_result.data
    delivery_printable.pdf.name = "delivery_labels.pdf"
    delivery_printable.save!
  end
end
