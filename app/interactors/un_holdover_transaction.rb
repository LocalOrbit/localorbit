class UnHoldoverTransaction
  include Interactor

  def perform
    result = Inventory::HoldoverOps.unholdover_product(user, params)
  end
end