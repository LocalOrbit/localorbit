class ProcessPackingLabelsPrintable
  include Interactor

  def perform
    require_in_context(:market_id, :packing_labels_printable_id, :request,
      :product_labels_only, :product_label_format,
      :print_multiple_labels_per_item, :delivery_date)
    delivery_printable = PackingLabelsPrintable.find packing_labels_printable_id
    delivery = delivery_printable.delivery
    user = delivery_printable.user

    if user.buyer_only? || user.market_manager?
      d_scope = "DATE(deliveries.buyer_deliver_on) = '#{delivery_date}'"
      d_group = "deliveries.buyer_deliver_on, orders.id"
      d_select = "deliveries.buyer_deliver_on, orders.*"
    else
      d_scope = "DATE(deliveries.deliver_on) = '#{delivery_date}'"
      d_group = "deliveries.deliver_on, orders.id"
      d_select = "deliveries.deliver_on, orders.*"
    end
    orders = Order.joins(:items, :delivery)
                  .where(order_items: {delivery_status: "pending"})
                  .where(d_scope)
                  .where(orders: {market_id: market_id})
                  .order(:order_number).group(d_group)
                  .select(d_select)


    orders = orders.for_seller(user).sort_by(&:billing_organization_name)
    seller_orders = orders.map do |o| SellerOrder.new(o,user) end

    # pdf_result = PackingLabels::Generator.generate(orders: orders, request: request)
    result = PackingLabels::Generator.generate(orders: seller_orders, request: request, product_labels_only: product_labels_only, product_label_format: product_label_format, print_multiple_labels_per_item: print_multiple_labels_per_item)
    if product_label_format == 1 # Zebra label format
      delivery_printable.zpl = result
      delivery_printable.zpl_name = "delivery_labels.zpl"
      delivery_printable.save!
    else
      delivery_printable.pdf = result.data
      delivery_printable.pdf.name = "delivery_labels.pdf"
      delivery_printable.save!
    end
  end
end
