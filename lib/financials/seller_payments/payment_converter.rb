module Financials
  module SellerPayments
    class PaymentConverter
      class << self
        include Financials::SellerPayments::Schema

        def seller_section_to_payment_info(seller_section:,bank_account_id:)
          seller_org = Organization.find(seller_section[:seller_id])
          order_ids = seller_section[:order_rows].map { |r| r[:order_id] }
          orders = Order.for_seller(seller_org.users.first).find(order_ids)
          owed = seller_section[:seller_totals][:net_sales]
          bank_account = nil
          if seller_section[:payable_accounts_for_select].detect { |(name,id)| id == bank_account_id }
            bank_account = seller_org.bank_accounts.find(bank_account_id)
          else
            raise "BankAccount '#{bank_account_id}' is not a payable bank account for Seller organization #{seller_section[:seller_id]}"
          end
          market = seller_org.markets.first
          
          payment_info = {
            payee:        seller_org,
            bank_account: bank_account,
            amount:       owed,
            market:       market,
            orders:       orders,
          }
          
          return SchemaValidation.validate!(PaymentInfo, payment_info)
          
        end
      end
    end
  end
end
