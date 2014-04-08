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
    @order = SellerOrder.new(order, seller) # Selling users organizations only see 

    mail(
      to: seller.users.pluck(:email),
      subject: "You have a new order!"
    )
  end

  def market_manager_confirmation(order, manager)
    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: manager.email,
      subject: "Thank you for your order"
    )
  end
end
