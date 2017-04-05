class CreateHoldoverTransaction
  include Interactor

  def perform
    result = Inventory::HoldoverOps.holdover_product(user, order, params)
  end
end