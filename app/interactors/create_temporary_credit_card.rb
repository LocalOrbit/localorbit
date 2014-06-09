class CreateTemporaryCreditCard
  include Interactor

  def perform
    unless order_params["credit_card"]["id"].present?
      temp_card = cart.organization.bank_accounts.create(order_params["credit_card"])
      temp_card.soft_delete

      context[:temp_card] = temp_card

      unless temp_card.valid?
        context.fail!
      end
    end
  end
end
