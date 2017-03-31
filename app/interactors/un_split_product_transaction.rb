class UnSplitProductTransaction
  include Interactor

  def perform
    result = Inventory::SplitOps.unsplit_product(params["product_id"])
  end
end