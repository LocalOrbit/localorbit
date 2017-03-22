class UnShrinkTransaction
  include Interactor

  def perform
    result = Inventory::ShrinkOps.unshrink_product(params)
  end
end