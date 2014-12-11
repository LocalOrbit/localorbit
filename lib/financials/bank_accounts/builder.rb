module Financials
  module BankAccounts
    class Builder
      class << self
        def options_for_select(bank_accounts: bank_accounts)
          bank_accounts.map do |acct|
            [acct.display_name, acct.id]
          end
        end
      end
    end
  end
end
