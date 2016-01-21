class SendOrderEmails
  include Interactor

  def perform
    unless order.organization.users.empty?
      OrderMailer.delay.buyer_confirmation(order)
    end

    order.sellers.each do |seller|
      unless seller.users.empty? || !seller.active?

        @pack_lists = OrdersBySellerPresenter.new(order.items, seller)
        @delivery = Delivery.find(order.delivery.id).decorate

        pdf = PackingLists::Generator.generate_pdf(request: request, pack_lists: @pack_lists, delivery: @delivery)
        csv = PackingLists::Generator.generate_csv(pack_lists: @pack_lists)

        OrderMailer.delay.seller_confirmation(order, seller, pdf, csv)
      end
    end

    unless order.market.managers.empty?
      OrderMailer.delay.market_manager_confirmation(order)
    end
  end
end
