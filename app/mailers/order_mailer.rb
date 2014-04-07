class OrderMailer < ActionMailer::Base
  layout "email"
  default from: "service@localorb.it"

  def buyer_confirmation(order)
    @market = order.market
    @user = order.placed_by
    @order = BuyerOrder.new(order)

    mail(
      to: @user.email,
      subject: "Thank you for your order"
    )
  end

  def seller_confirmation(order, seller)
    @market = order.market
    @order = SellerOrder.new(order, seller)

    mail(
      to: seller.email,
      subject: "You have a new order!"
    )
  end
end
