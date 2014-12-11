module Financials
  module SellerPayments
    module Schema
      Money = Financials::Schema::Money

      Totals = {
        net_sales:               Money,
        gross_sales:             Money,
        market_fees:             Money,
        transaction_fees:        Money,
        payment_processing_fees: Money,
        discounts:               Money,
      }

      OrderRow = {
        order_id:                Integer,
        order_number:            String,
        order_totals:            Totals,
        delivery_status:         Financials::Schema::DeliveryStatus,
        buyer_payment_status:    Financials::Schema::PaymentStatus,
        seller_payment_status:   Financials::Schema::PaymentStatus,
        payment_method:          Financials::Schema::PaymentMethod
      }

      SellerSection = {
        seller_id:                   Integer,
        seller_name:                 String,
        payable_accounts_for_select: [ Financials::Schema::AccountOption ],
        order_rows:                  [ OrderRow ],
        seller_totals:               Totals
      }
      
    end
  end
end
