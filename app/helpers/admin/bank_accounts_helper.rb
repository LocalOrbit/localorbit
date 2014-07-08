module Admin
  module BankAccountsHelper
    def expiration_month_options
      12.times.map {|month| month + 1 }
    end

    def expiration_year_options
      10.times.map do |i|
        i.years.from_now.year
      end
    end

    def is_credit_card?(bank_account)
      bank_account.account_type.present? && !("checking" == bank_account.account_type || "savings" == bank_account.account_type)
    end

    def selected_type(bank_account)
      if bank_account.account_type.nil? || ("checking" == bank_account.account_type || "savings" == bank_account.account_type)
        bank_account.account_type
      else
        "card"
      end
    end

    def account_type_options(bank_account)
      options_for_select(
        [
          ["Checking", "checking"],
          ["Savings", "savings"],
          ["Credit Card", "card"]
        ],
        selected: selected_type(bank_account)
      )
    end
  end
end
