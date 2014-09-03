class PaymentDecorator < Draper::Decorator
  include Draper::LazyHelpers

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
    display_entity(refund? ? payee : payer)
  end

  def to
    display_entity(refund? ? payer : payee)
  end

  def display_amount
    number_to_currency(refund? ? amount*-1 : amount)
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
