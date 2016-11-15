class RemoveCredit
  include Interactor

  def perform
    if !order.credit.nil?
      order.credit.soft_delete
    end
  end
end
