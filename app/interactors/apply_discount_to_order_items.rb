class ApplyDiscountToOrderItems
  include Interactor

  def perform
    return unless order.discount

    discounted_items.each do |item|
      discount_amount = (order.discount_amount * item.gross_total / subtotal).round(2)

      if order.discount.market?
        item.discount_market = discount_amount
      else
        item.discount_seller = discount_amount
      end
    end

    discount_field = order.discount.market? ? :discount_market : :discount_seller

    while (curr_discount = discounted_items.each.sum(&:discount)) != order.discount_amount
      limit = (curr_discount - order.discount_amount).abs * 100
      items = order.items.sort {|a, b| b.discount <=> a.discount }[0, limit.to_i]
      if curr_discount > order.discount_amount
        items.each {|i| i.decrement(discount_field, BigDecimal.new("0.01")) }
      else
        items.each {|i| i.increment(discount_field, BigDecimal.new("0.01")) }
      end
    end
  end

  def discounted_items
    @discounted_items ||= if restrict_to_seller_items?
      order.items.select {|i| i.product.organization_id == order.discount.seller_organization_id }
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
