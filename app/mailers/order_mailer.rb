class OrderMailer < BaseMailer
  def market_manager_order_updated(order)
    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items
    mail(
      to: @market.managers.map(&:pretty_email),
      subject: "#{@market.name}: Order #{order.order_number} Updated",
      template_name: 'order_updated'
    )
  end

  def market_manager_confirmation(order)
    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items
    mail(
      to: @market.managers.map(&:pretty_email),
      subject: "New order on #{@market.name}"
    )
  end

  def invoice(order_id)
    @order  = BuyerOrder.new(Order.find(order_id))
    return if @order.blank?
    to_list = recipient_list(@order.organization)
    return if to_list.blank?

    @market = @order.market
    attachments['invoice.pdf'] = {mime_type: 'application/pdf', content: @order.invoice_pdf.try(:data)}
    mail(
      to: to_list,
      subject: 'New Invoice'
    )
  end

  def buyer_confirmation(order)
    ensure_buysell_and_list(order, order.organization) do |to_list|
      @order = BuyerOrder.new(order)
      mail(
        to: to_list,
        subject: 'Thank you for your order'
      )
    end
  end

  def buyer_order_updated(order)
    ensure_buysell_and_list(order, order.organization) do |to_list|
      @order = BuyerOrder.new(order) # Market Managers should see all items
      mail(
        to: to_list,
        subject: "#{@market.name}: Order #{order.order_number} Updated",
        template_name: 'order_updated'
      )
    end
  end

  def buyer_order_removed(order)
    ensure_buysell_and_list(order, order.organization) do |to_list|
      @order = BuyerOrder.new(order) # Market Managers should see all items
      mail(
          to: to_list,
          subject: "#{@market.name}: Order #{order.order_number} Updated - Item Removed",
          template_name: 'order_updated'
      )
    end
  end

  def seller_confirmation(order, seller)
    ensure_buysell_and_list(order, seller) do |to_list|
      @order = SellerOrder.new(order, seller)
      @seller = seller
      mail(
        to: to_list,
        subject: "New order on #{@market.name}"
      )
    end
  end

  def seller_order_updated(order, seller)
    ensure_buysell_and_list(order, seller) do |to_list|
      @order = SellerOrder.new(order, seller)
      mail(
        to: to_list,
        subject: "#{@market.name}: Order #{order.order_number} Updated",
        template_name: 'order_updated'
      )
    end
  end

  def seller_order_item_removal(order, seller)
    ensure_buysell_and_list(order, seller) do |to_list|
      @order = SellerOrder.new(order, seller)
      mail(
        to: to_list,
        subject: "#{@market.name}: Order #{order.order_number} Updated - Item Removed",
        template_name: 'order_updated'
      )
    end
  end

  private

  def ensure_buysell_and_list(order, seller )
    send_to_list = recipient_list(seller)
    return if send_to_list.blank?
    @market = order.market

    yield send_to_list
  end

  def recipient_list(organization)
    organization.
      users.
      confirmed.
      map { |u| u.enabled_for_organization?(organization) ? u.pretty_email : nil}.
      compact
  end
end
