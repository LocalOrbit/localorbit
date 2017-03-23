class UnHoldoverTransaction
  include Interactor

  def perform
    result = Inventory::HoldoverOps.unholdover_product(params)
  end
end