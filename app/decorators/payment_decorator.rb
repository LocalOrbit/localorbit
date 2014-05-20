class PaymentDecorator < Draper::Decorator
  delegate_all

  def display_payment_type
    case payment_type
    when "cash"
      "Cash"
    when "check"
      note.present? ? "Check: #{note}" : "Check"
    when "ach"
      bank_account.present? ? "ACH: *********#{bank_account.last_four}" : "ACH"
    when "credit card"
      bank_account.present? ? "Credit Card: ************#{bank_account.last_four}" : "Credit Card"
    end
  end
end
