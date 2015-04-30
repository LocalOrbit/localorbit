class CreateTemporaryStripeCreditCard
  include Interactor

  def perform
    if order_params["payment_method"] == "credit card" && order_params["credit_card"]["id"].blank?
      @org = cart.organization

      # Munge card params:
      credit_card_params = order_params["credit_card"]
      should_save_card = credit_card_params.delete(:save_for_future) == "on"
      unless should_save_card
        credit_card_params.merge!(deleted_at: Time.current)
      end
      stripe_tok = credit_card_params.delete(:stripe_tok)

      bank_account = if existing_bank_account = find_bank_account(@org, credit_card_params)
                       # use this account
                       existing_bank_account
                     else
                       # create new card in Stripe and add to our Stripe customer
                       create_stripe_card_bank_account(@org, stripe_tok, credit_card_params)
                     end
      
      set_card_for_transaction(bank_account)
    end
  end

  private

  def find_bank_account(org, params)
    org.bank_accounts.visible.where(
      account_type: params[:account_type],
      last_four: params[:last_four],
      bank_name: params[:bank_name],
      name: params[:name]
    ).first
  end

  def set_card_for_transaction(bank_account)
    context[:order_params]["credit_card"]["id"] = bank_account.id
  end

  def create_stripe_card_bank_account(org, stripe_tok, card_params)
    customer = Stripe::Customer.retrieve(org.stripe_customer_id)
    card = customer.sources.create(source: stripe_tok)
    org.bank_accounts.create!(card_params.merge(stripe_id: card.id))
  rescue => e
    if Rails.env.test? || Rails.env.development?
      raise e
    else
      Honeybadger.notify_or_ignore(e)
    end
    context[:order].errors.add(:credit_card, "was denied by the payment processor.")
    context.fail!
  end

end
