RSpec.configure do |config|
  clear_payments = -> { 
    Financials::PaymentExecutor.previously_captured_payments.clear
  }
  config.before(:each) do
    clear_payments.call()
  end

  config.after(:each) do
    clear_payments.call()
  end
end
