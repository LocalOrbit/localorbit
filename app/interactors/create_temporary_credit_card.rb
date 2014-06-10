class CreateTemporaryCreditCard
  include Interactor

  def perform
    unless order_params["credit_card"]["id"].present?
      temp_card = cart.organization.bank_accounts.create(order_params["credit_card"])
      if temp_card.valid?
        temp_card.soft_delete
        context[:order_params]["credit_card"]["id"] = temp_card.id
      else
        context.fail!
      end
    end
  end
end
