module Financials
  module MarketPayments
    class Builder
      class << self
        include Financials::MarketPayments::Schema

        def build_market_section(market:, orders:)
          order_rows = orders.map { |o| build_order_row(o) }.sort_by do |r| r[:order_number] end

          all_order_totals = order_rows.map { |r| r[:order_totals] }
          market_totals = DataCalc.sums_of_keys(all_order_totals)

          account_options = Financials::BankAccounts::Builder.options_for_select(
            bank_accounts: Financials::BankAccounts::Finder.creditable_bank_accounts(
              bank_accounts: market.bank_accounts))

          market_section = {
            market_id: market.id,
            market_name: market.name,
            order_rows: order_rows,
            payable_accounts_for_select: account_options,
            market_totals: market_totals
          }
          
          return valid(MarketSection, market_section)
        end

        def build_order_row(order)
          order_totals = build_order_totals(order)
          order_row = {
            order_id: order.id,
            order_number: order.order_number,
            order_totals: order_totals
          }
          return valid(OrderRow, order_row)
        end

        def build_order_totals(order)
          totals = {}
          totals[:order_total]  = order.total_cost
          totals[:market_fee]   = Financials::MarketPayments::Calc.market_fee(order)
          totals[:delivery_fee] = Financials::MarketPayments::Calc.market_delivery_fee(order)
          totals[:owed]         = totals[:delivery_fee] + totals[:market_fee]

          return valid(Totals, totals)
        end

        private

        def valid(schema, object)
          SchemaValidation.validate!(schema,object)
        end

      end
    end
  end
end
