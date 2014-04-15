module Admin
  module BankAccountsHelper
    def expiration_month_options
      12.times.map {|month| month + 1}
    end

    def expiration_year_options
      10.times.map do |i|
        i.years.from_now.year
      end
    end
  end
end
