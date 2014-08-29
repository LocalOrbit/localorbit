class OrderMailer < BaseMailer
  def buyer_confirmation(order)
    @market = order.market
    @order = BuyerOrder.new(order)

    mail(
      to: order.organization.users.map(&:pretty_email),
      subject: "Thank you for your order"
    )
  end

  def seller_confirmation(order, seller)
    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    mail(
      to: seller.users.map(&:pretty_email),
      subject: "New order on #{@market.name}"
    )
  end

  def market_manager_confirmation(order)
    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.market.managers.map(&:pretty_email),
      subject: "New order on #{@market.name}"
    )
  end

  def invoice(order_id)
    @order  = BuyerOrder.new(Order.find(order_id))
    @market = @order.market

    attachments["invoice.pdf"] = {mime_type: "application/pdf", content: @order.invoice_pdf.try(:data)}

    result = mail(
      to: @order.organization.users.map(&:pretty_email),
      subject: "New Invoice"
    )
  end

  def buyer_order_updated(order)
    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.organization.users.map(&:pretty_email),
      subject: "#{@market.name}: Order #{order.order_number} updated",
      template_name: "order_updated"
    )
  end

  def seller_order_updated(order, seller)
    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    mail(
      to: seller.users.map(&:pretty_email),
      subject: "#{@market.name}: Order #{order.order_number} updated",
      template_name: "order_updated"
    )
  end

  def market_manager_order_updated(order)
    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.market.managers.map(&:pretty_email),
      subject: "#{@market.name}: Order #{order.order_number} updated",
      template_name: "order_updated"
    )
  end
end
