if Figaro.env.capture_payments == 'TRUE'
  Financials::PaymentExecutor.capture_payments = true

elsif Figaro.env.capture_payments == 'FALSE'
  Financials::PaymentExecutor.capture_payments = false

else
  # Capture payments in test mode by default:
  if Rails.env.test?
    Financials::PaymentExecutor.capture_payments = true
  else
    Financials::PaymentExecutor.capture_payments = false
  end
end
