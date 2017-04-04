class UnRepackTransaction
  include Interactor

  def perform
    result = Inventory::RepackOps.unrepack_product(user, params)
  end
end