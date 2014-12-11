module Financials
  module BankAccounts
    class Finder
      class << self
        def creditable_bank_accounts(bank_accounts: bank_accounts)
          bank_accounts.
            verified.
            creditable_bank_accounts.
            sort_by(&:display_name)
        end
      end
    end
  end
end
