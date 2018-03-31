class SendOrderEmails
  include Interactor

  def perform
    unless order.organization.users.empty?
      OrderMailer.delay(priority: 10).buyer_confirmation(order)
    end

    if Pundit.policy(context[:user], :all_supplier)
      order.sellers.each do |seller|
        unless seller.users.empty? || !seller.active?

          @pack_lists = OrdersBySellerPresenter.new(order.items, seller)
          @delivery = Delivery.find(order.delivery.id).decorate

          begin
            pdf = PackingLists::Generator.generate_pdf(request: request, pack_lists: @pack_lists, delivery: @delivery)
          rescue RuntimeError => e
            pdf = nil
            Rollbar.error(e, 'Failed to generate packing list PDF for seller order confirmation email', order_id: order.id)
          end

          csv = PackingLists::Generator.generate_csv(pack_lists: @pack_lists)

          OrderMailer.delay(priority: 10).seller_confirmation(order, seller, pdf, csv)
        end
      end
    end

    unless order.market.managers.empty?
      OrderMailer.delay(priority: 10).market_manager_confirmation(order)
    end
  end
end
