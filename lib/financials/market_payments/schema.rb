module Financials
  module MarketPayments
    module Schema
      Money = Financials::Schema::Money

      # TODO: Consider sharing structure with SellerPayments::Schema::Totals ?
      Totals = {
        owed:         Money,
        order_total:  Money,
        delivery_fee: Money,
        market_fee:   Money,
      }

      OrderRow = {
        order_id:                Integer,
        order_number:            String,
        order_totals:            Totals,
      }

      MarketSection = {
        market_id:                   Integer,
        market_name:                 String,
        payable_accounts_for_select: [ Financials::Schema::AccountOption ],
        order_rows:                  [ OrderRow ],
        market_totals:               Totals
      }
      
      # PaymentInfo = {
      #   payee:        Organization,
      #   bank_account: BankAccount,
      #   amount:       Money,
      #   market:       Market,
      #   orders:       [Order]
      # }
    end
  end
end
