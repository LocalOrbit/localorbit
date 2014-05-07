class OrderMailer < BaseMailer
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

  def invoice(order_id, addresses)
    @order  = BuyerOrder.new(Order.find(order_id))
    @market = @order.market

    user = User.find_by(email: addresses)

    scheme = Rails.env.production? || Rails.env.staging? ? "https://" : "http://"
    uri = URI("#{scheme}#{@order.market.subdomain}.#{Figaro.env.domain}/admin/invoices/#{@order.id}/invoice.pdf?auth_token=#{user.auth_token}")

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https'), verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request Net::HTTP::Get.new(uri)
    end

    attachments["invoice.pdf"] = {mime_type: "application/pdf", content: res.body}

    mail(
      to: addresses,
      subject: "New Invoice"
    )
  end
end
