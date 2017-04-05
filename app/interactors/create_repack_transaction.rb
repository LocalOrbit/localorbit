class CreateRepackTransaction
  include Interactor

  def perform
    result = Inventory::RepackOps.repack_product(user, order, params)
  end
end