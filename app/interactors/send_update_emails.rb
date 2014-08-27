class SendUpdateEmails
  include Interactor

  def perform

    unless order.organization.users.empty?
      OrderMailer.delay.buyer_order_updated(order)
    end

    order.sellers_with_changes.each do |seller|
      unless seller.users.empty?
        OrderMailer.delay.seller_order_updated(order, seller)
      end
    end

    unless order.market.managers.empty?
      OrderMailer.delay.market_manager_order_updated(order)
    end
  end
end
