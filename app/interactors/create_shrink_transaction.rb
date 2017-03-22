class CreateShrinkTransaction
  include Interactor

  def perform
    result = Inventory::ShrinkOps.shrink_product(order, params)
  end
end