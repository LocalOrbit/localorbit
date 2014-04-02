class DeleteCart
  include Interactor

  def perform
    cart.destroy
  end
end
