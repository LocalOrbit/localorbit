class SendOrderEmails
  include Interactor

  def perform
    OrderMailer.buyer_confirmation(order).deliver

    order_seller_users = order.sellers.map(&:users).flatten.uniq
    order_seller_users.each do |seller|
      OrderMailer.seller_confirmation(order, seller).deliver
    end

    order.market.managers.each do |manager|
      OrderMailer.market_manager_confirmation(order, manager).deliver
    end
  end
end
