class ChargeServiceFee
  include Interactor

  def perform
    payment = setup_payment

    begin
      debit = setup_debit
      payment.update_attributes(balanced_uri: debit.uri)
    rescue => e
      updates = {status: "failed"}
      if e.try(:category_code).present?
        updates[:note] = [payment.note, "Error: #{e.category_code}"].reject(&:blank?).join(" ")
      end
      payment.update_attributes(updates)
      context.fail!
    end
  end

  private

  def setup_debit
    market.balanced_customer.debit(
      amount:                  (amount * 100).to_i,
      source_uri:              bank_account.balanced_uri,
      description:             "Local Orbit Service fee",
      appears_on_statement_as: "Local Orbit"
    )
  end

  def setup_payment
    Payment.create({
      payment_type:   "service",
      market:         market,
      payer:          market,
      amount:         amount,
      bank_account:   bank_account,
      payment_method: bank_account.bank_account? ? "ach" : "credit card",
      status:         bank_account.bank_account? ? "pending" : "paid"
    })
  end
end
