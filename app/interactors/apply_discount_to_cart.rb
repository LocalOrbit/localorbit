class ApplyDiscountToCart
  include Interactor

  def perform
    if discount = Discount.where(code: code).first
      if can_use_discount?(discount)
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
    discount.maximum_uses == 0 || discount.maximum_uses < discount.total_uses
  end
end
