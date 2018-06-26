class PaymentPreview < ApplicationPreview

  def payment_made
    PaymentMailer.payment_made([build(:user).email], build_stubbed(:payment))
  end

  def payment_received
    PaymentMailer.payment_received([build(:user).email], build_stubbed(:payment))
  end

end
