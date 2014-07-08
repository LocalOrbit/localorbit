class PaymentDecorator < Draper::Decorator
  delegate_all

  def display_payment_method
    case payment_method
    when "cash"
      "Cash"
    when "check"
      note.present? ? "Check: #{note}" : "Check"
    when "ach"
      bank_account.present? ? "ACH: *********#{bank_account.last_four}" : "ACH"
    when "credit card"
      bank_account.present? ? "Credit Card: ************#{bank_account.last_four}" : "Credit Card"
    when "paypal"
      "PayPal"
    end
  end

  def from
    display_entity(payer)
  end

  def to
    display_entity(payee)
  end

  private

  def display_entity(entity)
    if entity.nil?
      "Local Orbit"
    else
      entity.name
    end
  end
end
