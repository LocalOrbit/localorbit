class OrderMailer < BaseMailer
  def buyer_confirmation(order)
    @market = order.market
    return if @market.is_consignment_market?

    @order = BuyerOrder.new(order)

    to_list = recipient_list(order)

    if !to_list.blank?
      mail(
        to: to_list,
        subject: 'Thank you for your order'
      )
    end
  end

  def seller_confirmation(order, seller)
    @market = order.market
    return if @market.is_consignment_market?

    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    to_list = seller.
                users.
                confirmed.
                map { |u| u.enabled_for_organization?(seller) && !u.pretty_email.nil? ? u.pretty_email : nil}.
                compact

    if !to_list.blank?
      mail(
        to: to_list,
        subject: "New order on #{@market.name}"
      )
    end
  end

  def market_manager_confirmation(order)
    @market = order.market
    return if @market.is_consignment_market?

    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.market.managers.map(&:pretty_email),
      subject: "New order on #{@market.name}"
    )
  end

  def invoice(order_id)

    @order  = BuyerOrder.new(Order.find(order_id))
    @market = @order.market
    return if @market.is_consignment_market?

    attachments['invoice.pdf'] = {mime_type: 'application/pdf', content: @order.invoice_pdf.try(:data)}

    to_list = recipient_list(@order)
    if !to_list.blank?
      mail(
        to: to_list,
        subject: 'New Invoice'
      )
    end
  end

  def buyer_order_updated(order)
    @market = order.market
    return if @market.is_consignment_market?

    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: recipient_list(order),
      subject: "#{@market.name}: Order #{order.order_number} Updated",
      template_name: 'order_updated'
    )
  end

  def buyer_order_removed(order)
    @market = order.market
    return if @market.is_consignment_market?

    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
        to: recipient_list(order),
        subject: "#{@market.name}: Order #{order.order_number} Updated - Item Removed",
        template_name: 'order_updated'
    )
  end

  def seller_order_updated(order, seller)
    return if order.market.is_consignment_market?

    to_list = seller.
                users.
                map { |u| u.enabled_for_organization?(seller) ? u.pretty_email : nil}.
                compact

    return if to_list.blank?

    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    mail(
      to: to_list,
      subject: "#{@market.name}: Order #{order.order_number} Updated",
      template_name: 'order_updated'
    )
  end

  def market_manager_order_updated(order)
    return if order.market.is_consignment_market?

    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.market.managers.map(&:pretty_email),
      subject: "#{@market.name}: Order #{order.order_number} Updated",
      template_name: 'order_updated'
    )
  end

  def seller_order_item_removal(order, seller)
    return if order.market.is_consignment_market?

    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    mail(
        to: seller.users.map(&:pretty_email),
        subject: "#{@market.name}: Order #{order.order_number} Updated - Item Removed",
        template_name: 'order_updated'
    )
  end

  private

  def recipient_list(order)
    order.
      organization.
      users.
      confirmed.
      map { |u| u.enabled_for_organization?(order.organization) ? u.pretty_email : nil}.
      compact
  end
end
