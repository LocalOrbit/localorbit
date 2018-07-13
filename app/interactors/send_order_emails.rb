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

          OrderMailer.delay(priority: 10).seller_confirmation(order, seller)
        end
      end
    end

    unless order.market.managers.empty?
      OrderMailer.delay(priority: 10).market_manager_confirmation(order)
    end
  end
end
