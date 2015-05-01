module Financials
  module MoneyHelpers
    extend self

    def amount_to_cents(amount)
      (amount * 100).to_i
    end

    def cents_to_amount(cents)
      cents.to_d / 100
    end
  end
end
