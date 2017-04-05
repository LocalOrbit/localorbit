class UnRepackTransaction
  include Interactor

  def perform
    result = Inventory::RepackOps.unrepack_product(user, order, params)
  end
end