class CreateShrinkTransaction
  include Interactor

  def perform
    result = Inventory::ShrinkOps.shrink_product(user, order, params)
  end
end