class CreateTemporaryCreditCard
  include Interactor

  def perform
    if order_params["payment_method"] == 'credit card' && order_params["credit_card"]["id"].blank?
      org = cart.organization

      credit_card_params = order_params["credit_card"]
      credit_card_params.merge!(deleted_at: Time.current) unless order_params["credit_card"]["save_for_future"] == "on"

      temp_card = org.bank_accounts.create(credit_card_params)
      if temp_card.valid?
        begin
          org.balanced_customer.add_card(temp_card.balanced_uri)
          context[:order_params]["credit_card"]["id"] = temp_card.id
        rescue Exception => e
          if Rails.env.test? || Rails.env.development?
            raise e
          else
            Honeybadger.notify_or_ignore(e)
          end

          context[:order].errors.add(:credit_card, "was denied by the payment processor.")
          context.fail!
        end
      else
        puts temp_card.errors.inspect
        context[:credit_card] = temp_card
        context.fail!
      end
    end
  end
end
