class CreateTemporaryCreditCard
  include Interactor

  def perform
    if order_params["payment_method"] == 'credit card' && order_params["credit_card"]["id"].blank?
      @org = cart.organization

      @credit_card_params = order_params["credit_card"]
      @credit_card_params.merge!(deleted_at: Time.current) unless should_save_card?

      temp_card = @org.bank_accounts.create(@credit_card_params)
      if temp_card.valid?
        set_card_for_transaction(temp_card)
      else
        # Handles case in which buyer enters a credit
        # card they have already saved
        if temp_card.errors.messages.keys == [:bankable_id]
          accounts = @org.bank_accounts.visible.where(
            account_type: @credit_card_params[:account_type],
            last_four: @credit_card_params[:last_four],
            bank_name: @credit_card_params[:bank_name],
            name: @credit_card_params[:name]
          )

          temp_card = accounts.first
          set_card_for_transaction(temp_card)
        else
          context[:credit_card] = temp_card
          context.fail!
        end
      end
    end
  end

  private

  def set_card_for_transaction(temp_card)
    begin
      @org.balanced_customer.add_card(temp_card.balanced_uri)
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
  end

  def should_save_card?
    save_option = @credit_card_params.delete(:save_for_future)
    save_option == 'on'
  end
end
