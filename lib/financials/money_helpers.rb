module Financials
  module MoneyHelpers
    extend self

    def amount_to_cents(amount)
      (amount * 100).to_i
    end
  end
end
