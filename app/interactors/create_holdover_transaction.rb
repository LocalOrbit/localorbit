class CreateHoldoverTransaction
  include Interactor

  def perform
    result = Inventory::HoldoverOps.holdover_product(order, params)
  end
end