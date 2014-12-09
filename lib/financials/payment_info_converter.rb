module Financials
  class PaymentInfoConverter
    class << self
      def seller_net_payment_info(seller_section:,bank_account_id:)
        #
        # Amount
        #
        amount = seller_section[:seller_totals][:net_sales]

        #
        # Payee
        #
        seller_org = Organization.find(seller_section[:seller_id])

        #
        # Market
        #
        market = seller_org.markets.first

        #
        # Orders
        #
        order_ids = seller_section[:order_rows].map { |r| r[:order_id] }
        orders = Order.find(order_ids)


        #
        # Bank Account
        #
        bankable = seller_org
        bank_account = nil
        if seller_section[:payable_accounts_for_select].detect { |(name,id)| id == bank_account_id }
          bank_account = bankable.bank_accounts.find(bank_account_id)
        else
          raise "BankAccount '#{bank_account_id}' is not a payable bank account for Seller organization #{seller_section[:seller_id]}"
        end

        payment_info = {
          payee:        seller_org,
          bank_account: bank_account,
          amount:       amount,
          market:       market,
          orders:       orders,
        }
        
        return SchemaValidation.validate!(Financials::Schema::PaymentInfo, payment_info)
      end

      def market_hub_fee_payment_info(market_section:,bank_account_id:)
        amount = market_section[:market_totals][:market_fee]
        _market_payment_info market_section, bank_account_id, amount: amount
      end

      def market_delivery_fee_payment_info(market_section:,bank_account_id:)
        amount = market_section[:market_totals][:delivery_fee]
        _market_payment_info market_section, bank_account_id, amount: amount
      end

      private

      def _market_payment_info(market_section,bank_account_id, amount:)
        market = Market.find(market_section[:market_id])
        
        order_ids = market_section[:order_rows].map { |r| r[:order_id] }
        orders = Order.find(order_ids)

        bankable = market
        bank_account = nil
        if market_section[:payable_accounts_for_select].detect { |(name,id)| id == bank_account_id }
          bank_account = bankable.bank_accounts.find(bank_account_id)
        else
          raise "BankAccount '#{bank_account_id}' is not a payable bank account for Market #{market.id}"
        end

        payment_info = {
          payee:        market,
          bank_account: bank_account,
          market:       market,
          orders:       orders,
          amount:       amount
        }
        return SchemaValidation.validate!(Financials::Schema::PaymentInfo, payment_info)
      end
    end
  end
end
