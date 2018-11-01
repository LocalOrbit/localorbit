module CSVExport
  class CSVVendorPaymentsExportJob < Struct.new(:user, :market, :params) # pass in the datafile like is done right now in uploadcontroller, i.e.

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
      @search_presenter = PaymentSearchPresenter.new(user: user, query: params)
      @finder = Search::SellerPaymentGroupFinder.new(user: user, query: params, current_market: market)
      @sellers = @finder.payment_groups

      csv = CSV.generate do |f|
        f << ["Vendor","Market","Order ID","Placed At", "Delivery Status", "Payment Status", "Net Amount"]

        @sellers.each do |seller|
          seller.orders.each do |order|
            f << [
                seller.name,
                seller.market_name,
                order.order_number,
                order.placed_at.strftime("%b %d, %Y"),
                order.delivery_status_for_user(user).titleize,
                order.payment_status.titleize,
                order.net_total
            ]
          end
        end
      end

      # Send via email
      ExportMailer.delay(priority: 30).export_success(user.email, 'vendor_payments', csv.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''))
    end

  end
end