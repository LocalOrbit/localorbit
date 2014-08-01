class ApplyDiscountToCart
  include Interactor

  def perform
    discount = Discount.where(code: code).first
    if can_use_discount?(discount)
      if discount.minimum_order_total > 0 && discount.minimum_order_total > cart.subtotal
        context[:message] = "Discount code requires a minimum of #{"$%.2f" % discount.minimum_order_total}"
        context.fail!
      elsif discount_is_valid?(discount)
        cart.discount = discount
        cart.save
        context[:message] = "Discount applied"
      else
        context[:message] = "Discount code expired"
        context.fail!
      end
    else
      context[:message] = "Invalid discount code"
      context.fail!
    end
  end

  def can_use_discount?(discount)
    discount && can_use_in_market?(discount) && can_use_for_buyer?(discount)
  end

  def discount_is_valid?(discount)
    discount.active? && less_than_max_uses?(discount) && less_than_max_org_uses?(discount)
  end

  def can_use_in_market?(discount)
    (discount.market_id.nil? || discount.market_id == cart.market_id)
  end

  def can_use_for_buyer?(discount)
    (discount.buyer_organization_id.nil? || discount.buyer_organization_id == cart.organization.id)
  end

  def less_than_max_uses?(discount)
    discount.maximum_uses == 0 || discount.maximum_uses > discount.total_uses
  end

  def less_than_max_org_uses?(discount)
    discount.maximum_organization_uses == 0 || discount.maximum_organization_uses > discount.uses_by_organization(cart.organization)
  end
end
