module CSVExport
  class CSVOrderExportJob < Struct.new(:user, :ids)

    def enqueue(job)
    end

    def success(job)
    end

    def error(job, exception)
      puts exception
    end

    def failure(job)
    end

    def perform
      order_items = OrderItem.includes({order: :delivery}, :product).joins(:product).where(id: ids).order(:created_at)
      csv = CSV.generate do |f|
        f << [
            "LO Order Number",
            "Order Date",
            "Delivery Date",
            "Buyer",
            "Buyer Type",
            "PO Number",
            "Delivery Status",
            "Supplier",
            "Product Code",
            "Product",
            "Unit",
            "Product Unit Price",
            "Product Quantity",
            "Product Total"
        ]

        order_items.find_each do |order_item|
          f << [
              order_item.order.order_number,
              order_item.order.placed_at.strftime("%m/%d/%Y"),
              order_item.order.delivery && order_item.order.delivery.deliver_on.strftime("%m/%d/%Y"),
              order_item.order.organization.name,
              order_item.order.organization.buyer? && !order_item.order.organization.buyer_org_type.nil? ? order_item.order.organization.buyer_org_type : '',
              order_item.order.payment_note,
              order_item.delivery_status.titleize,
              order_item.product.organization.name,
              order_item.product.code,
              order_item.product.name,
              order_item.product.unit.singular,
              order_item.unit_price,
              order_item.quantity,
              order_item.gross_total
          ]
        end
      end

      # Send via email
      ExportMailer.delay(priority: 30).export_success(user.email, 'order', csv)
    end

  end
end
