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

    # Try to find a user that can actually log in
    user = @order.organization.users.where.not(confirmed_at: nil).first || @market.managers.where.not(confirmed_at: nil).first

    # encode "+" and other characters to be url safe
    auth_token = URI.encode_www_form_component(user.auth_token)

    scheme = Rails.env.production? || Rails.env.staging? ? "https://" : "http://"
    uri = URI("#{scheme}#{@order.market.subdomain}.#{Figaro.env.domain}/admin/invoices/#{@order.id}/invoice.pdf?auth_token=#{auth_token}")

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == "https"), verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request Net::HTTP::Get.new(uri)
    end

    res.value # Raises an exception if the response code isn't 2xx

    attachments["invoice.pdf"] = {mime_type: "application/pdf", content: res.body}

    mail(
      to: @order.organization.users.map(&:pretty_email),
      subject: "New Invoice"
    )
  end
end
