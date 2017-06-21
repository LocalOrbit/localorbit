class ApplyDiscountToAddedOrderItems
  include Interactor

  def perform
    return unless order.discount #&& order.payment_method == "purchase order"
    order_total = if order.discount.try(:seller_organization_id).present?
                    discounted_items.each.sum(&:gross_total)
                  else
                    subtotal
                  end
    discount_value = order.discount.value_for(order_total)

    discounted_items.each do |item|
      discount_amount = (discount_value * item.gross_total / subtotal).round(2)

      if order.discount.market?
        item.discount_market = discount_amount
      else
        item.discount_seller = discount_amount
      end
    end

    discount_field = order.discount.market? ? :discount_market : :discount_seller

    while (curr_discount = discounted_items.each.sum(&:discount)) != discount_value
      limit = (curr_discount - discount_value).abs * 100
      items = order.items.sort {|a, b| b.discount <=> a.discount }[0, limit]
      if curr_discount > discount_value
        items.each {|i| i.decrement(discount_field, BigDecimal.new("0.01")) }
      else
        items.each {|i| i.increment(discount_field, BigDecimal.new("0.01")) }
      end
    end
  end

  def discounted_items
    @discounted_items ||= if restrict_to_seller_items?
      #order.items.select {|i| i.product.organization_id == order.discount.seller_organization_id }
      order.items.joins(:product).where(products: {organization_id: order.discount.seller_organization_id})
    else
      order.items
    end
  end

  def subtotal
    @subtotal ||= restrict_to_seller_items? ? discounted_items.each.sum(&:gross_total) : order.subtotal
  end

  def restrict_to_seller_items?
    order.discount.seller_organization_id.present?
  end
end
