class AddBankAccountToManagedStripeAccount
  include Interactor

  def perform
    stripe_account = context[:stripe_account]
    bank_account = context[:bank_account]
    bank_account_params = context[:bank_account_params]

    # Create a Stripe bank account for the Stripe Account
    stripe_tok = bank_account_params[:stripe_tok]
    stripe_bank_account = stripe_account.bank_accounts.create(bank_account: stripe_tok)

    # Update bank account w stripe id
    bank_account.update(stripe_id: stripe_bank_account.id, account_role: 'deposit')
  end
end
