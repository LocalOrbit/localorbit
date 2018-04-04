module CSVExport
  class CSVSoldItemsExportJob < Struct.new(:user, :ids)

    def perform

      order_items = OrderItem.includes({order: :delivery}, :product).joins(:product).where(id: ids).order(:created_at)
      csv = CSV.generate do |f|
        f << [
          "Order Date",
          "Order #",
          "Market",
          "Supplier",
          "Buyer",
          "Product",
          "Price",
          "Qty",
          "Total",
          "Delivery",
          "Buyer $",
          "Supplier $"
        ]
        order_items.find_each do |order_item|
          order_item = order_item.decorate
          f << [
            order_item.placed_at,
            order_item.order_number,
            order_item.market_name,
            order_item.seller_name,
            order_item.buyer_name,
            order_item.product_name,
            order_item.price_per_unit,
            order_item.quantity,
            order_item.row_total, # ie. gross_total
            order_item.delivery_status,
            order_item.order.payment_status.titleize,
            order_item.seller_payment_status
          ]
        end
      end

      ExportMailer.delay.export_success(user.email, 'sold_items', csv)
    end

  end
end
