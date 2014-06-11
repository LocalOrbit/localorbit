class CreateTemporaryCreditCard
  include Interactor

  def perform
    unless order_params["credit_card"]["id"].present?
      org = cart.organization

      credit_card_params = order_params["credit_card"]
      credit_card_params.merge!(deleted_at: Time.current) unless order_params["credit_card"]["save_for_future"] == "on"

      temp_card = org.bank_accounts.create(order_params["credit_card"])

      if temp_card.valid?
        org.balanced_customer.add_card(temp_card.balanced_uri)
        context[:order_params]["credit_card"]["id"] = temp_card.id
      else
        context[:credit_card] = temp_card
        context.fail!
      end
    end
  end
end
