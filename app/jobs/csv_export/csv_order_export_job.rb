module CSVExport
  class CSVOrderExportJob < Struct.new(:user, :order_items) # pass in the datafile like is done right now in uploadcontroller, i.e.

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
      Dir.mkdir(Rails.root.join('tmp'))

      CSV.open("#{Rails.root}/tmp/#{user.id}_order_export.csv", "wb") do |f|
        f << [
            "LO Order Number",
            "Order Date",
            "Delivery Date",
            "Buyer",
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

        order_items.each do |order_item|
          f << [
              order_item.order.order_number,
              order_item.order.placed_at.strftime("%m/%d/%Y"),
              order_item.order.delivery && order_item.order.delivery.deliver_on.strftime("%m/%d/%Y"),
              order_item.order.organization.name,
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
      ExportMailer.delay.export_success(user.email, "#{Rails.root}/tmp/#{user.id}_order_export.csv")
    end

  end
end