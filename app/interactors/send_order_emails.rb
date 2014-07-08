class SendOrderEmails
  include Interactor

  def perform
    unless order.organization.users.empty?
      OrderMailer.buyer_confirmation(order).deliver
    end

    order.sellers.each do |seller|
      unless seller.users.empty?
        OrderMailer.seller_confirmation(order, seller).deliver
      end
    end

    unless order.market.managers.empty?
      OrderMailer.market_manager_confirmation(order).deliver
    end
  end
end
