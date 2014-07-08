class EnsureCartIsNotEmpty
  include Interactor

  def perform
    if cart.items.empty?
      fail!(
        message: "Your cart is empty. Please add items to your cart before checking out.",
        cart_is_empty: true
      )
    end
  end
end
