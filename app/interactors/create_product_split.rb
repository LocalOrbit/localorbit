class CreateProductSplit
  include Interactor

  def perform
    result = Inventory::SplitOps.split_product(params["parent_product_id"], params["product_id"], params["lot_id"], params["quantity"])
  end
end