class ApplyDiscountToCart
  include Interactor

  def perform
    if context[:code].present?
      discount = Discount.where(code: code).first

      if can_use_discount?(discount) && discount_is_valid?(discount)
        cart.discount = discount
        cart.save
      end
    else
      cart.update(discount_id: nil)
    end
  end

  def can_use_discount?(discount)
    if !discount || !discount.can_use_in_market?(cart) || !discount.can_use_for_buyer?(cart)
      context[:message] = "Invalid discount code"
      context.fail!
    end

    context.success?
  end

  def discount_is_valid?(discount)
    if discount.less_than_minimum?(cart)
      context[:message] = "Discount code requires a minimum of #{"$%.2f" % discount.minimum_order_total}"
      context.fail!
    elsif discount.more_than_maximum?(cart)
      context[:message] = "Discount code requires a maximum of #{"$%.2f" % discount.maximum_order_total}"
      context.fail!
    elsif discount.requires_seller_items?(cart)
      context[:message] = "Discount code requires items from #{discount.seller_organization.name}"
      context.fail!
    elsif !discount.active? || discount.maximum_uses_hit? || discount.maximum_organization_uses_hit?(cart)
      context[:message] = "Discount code expired"
      context.fail!
    else
      context[:message] = "Discount applied"
    end

    context.success?
  end
end
