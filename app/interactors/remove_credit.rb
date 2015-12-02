class RemoveCredit
  include Interactor

  def perform
      order.credit.soft_delete
  end
end
