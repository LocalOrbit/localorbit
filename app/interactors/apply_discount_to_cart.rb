class ApplyDiscountToCart
  include Interactor

  def perform
    if discount = Discount.where(code: code).first
      cart.discount = discount
      cart.save
      context[:message] = "Discount applied"
    else
      context[:message] = "Invalid discount code"
      context.fail!
    end
  end
end
