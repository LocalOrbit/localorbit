class OrderMailer < ActionMailer::Base
  layout "email"
  default from: "service@localorb.it"

  def buyer_confirmation(order)
    @market = order.market
    @order = BuyerOrder.new(order)

    mail(
      to: order.organization.users.pluck(:email),
      subject: "Thank you for your order"
    )
  end

  def seller_confirmation(order, seller)
    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see

    mail(
      to: seller.users.pluck(:email),
      subject: "New order on #{@market.name}"
    )
  end

  def market_manager_confirmation(order)
    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.market.managers.pluck(:email),
      subject: "New order on #{@market.name}"
    )
  end

  # TODO: Attach invoice PDF
  def invoice(order)
    @order = BuyerOrder.new(order)
    @email_addresses = @order.organization.users.map(&:email).join(", ")

    mail(
      to: @email_addresses,
      subject: "New Invoice"
    )
  end
end
