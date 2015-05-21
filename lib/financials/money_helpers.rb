module Financials
  module MoneyHelpers
    extend self

    def amount_to_cents(amount)
      return 0 if amount.nil?
      (amount * 100).to_i
    end

    def cents_to_amount(cents)
      return 0.to_d if cents.nil?
      cents.to_d / 100
    end
  end
end
