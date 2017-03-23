class CreateConsignmentProducts
  include Interactor

  def perform
    order = context[:order]
    ConsignmentProduct.upsert_items(order.items) if order.purchase_order?
  end

  def rollback
  end
end