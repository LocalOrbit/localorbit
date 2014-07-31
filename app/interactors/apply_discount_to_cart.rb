class ApplyDiscountToCart
  include Interactor

  def perform
    discount = Discount.where(code: code).first
    if can_use_discount?(discount)
      if discount_is_valid?(discount)
        cart.discount = discount
        cart.save
        context[:message] = "Discount applied"
      else
        context[:message] = "Discount code expired"
      end
    else
      context[:message] = "Invalid discount code"
      context.fail!
    end
  end

  def can_use_discount?(discount)
    discount && (discount.buyer_organization_id.nil? || discount.buyer_organization_id == cart.organization.id)
  end

  def discount_is_valid?(discount)
    less_than_max_uses?(discount) && less_than_max_org_uses?(discount)
  end

  def less_than_max_uses?(discount)
    discount.maximum_uses == 0 || discount.maximum_uses > discount.total_uses
  end

  def less_than_max_org_uses?(discount)
    discount.maximum_organization_uses == 0 || discount.maximum_organization_uses > discount.uses_by_organization(cart.organization)
  end
end
