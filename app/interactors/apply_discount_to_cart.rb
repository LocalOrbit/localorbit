class ApplyDiscountToCart
  include Interactor

  def perform
    discount = Discount.where(code: code).first

    if can_use_discount?(discount)
      if discount_is_valid?(discount)
        cart.discount = discount
        cart.save
      end
    end
  end

  def can_use_discount?(discount)
    if !discount || !can_use_in_market?(discount) || !can_use_for_buyer?(discount)
      context[:message] = "Invalid discount code"
      context.fail!
    end

    context.success?
  end

  def discount_is_valid?(discount)
    if less_than_minimum?(discount)
      context[:message] = "Discount code requires a minimum of #{"$%.2f" % discount.minimum_order_total}"
      context.fail!
    elsif !discount.active? || maximum_uses_hit?(discount) || maximum_organization_uses_hit?(discount)
      context[:message] = "Discount code expired"
      context.fail!
    else
      context[:message] = "Discount applied"
    end

    context.success?
  end

  def can_use_in_market?(discount)
    (discount.market_id.nil? || discount.market_id == cart.market_id)
  end

  def can_use_for_buyer?(discount)
    (discount.buyer_organization_id.nil? || discount.buyer_organization_id == cart.organization.id)
  end

  def less_than_minimum?(discount)
    discount.minimum_order_total > 0 && discount.minimum_order_total > cart.subtotal
  end

  def maximum_uses_hit?(discount)
    discount.maximum_uses > 0 && discount.maximum_uses <= discount.total_uses
  end

  def maximum_organization_uses_hit?(discount)
    discount.maximum_organization_uses > 0 && discount.maximum_organization_uses <= discount.uses_by_organization(cart.organization)
  end
end
