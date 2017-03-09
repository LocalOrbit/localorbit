class CreateConsignmentProducts
  include Interactor

  def perform
    order = context[:order]
    binding.pry
    ConsignmentProduct.upsert_items(order.items) if order.purchase_order?
    binding.pry
  end

  def rollback
  end
end