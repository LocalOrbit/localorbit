require 'tabulator'
module Financials
  module MarketPayments
    class Faker
      class << self
        def mk_order_rows(opts={},*data)
          order_number_prefix = opts[:order_number_prefix] || "LO-14-ALLENMARKETPLACE-000003"
          Tabulator.tabulate(6, data) do |row|
            row[:order_number] = "#{order_number_prefix}#{row[:order_number]}"
            row[:order_totals] = {}
            [:owed, :order_total, :delivery_fee, :market_fee].each do |k|
              row[:order_totals][k] = row.delete(k).to_d # convert these fields to BigDecimal values
            end
            row
          end
        end
        
        def mk_totals(order_rows)

          hsum = lambda do |hs,k| 
            hs.inject(0) { |sum,h| 
              if h[:order_totals][k].nil?
                binding.pry
              end
              sum + h[:order_totals][k] 
            }
          end

          {
            owed:           hsum[order_rows, :owed],
            order_total:    hsum[order_rows, :order_total],
            delivery_fee:   hsum[order_rows, :delivery_fee],
            market_fee:     hsum[order_rows, :market_fee],
          }
        end

        def mk_market_sections
          order_rows = mk_order_rows({},
            :order_id, :order_number, :owed,      :order_total, :delivery_fee, :market_fee,
            1,         "1",           "280.12",   "341.63",     "38.61",       "13.67",
            2,         "2",           "280.12",   "341.63",     "38.61",       "13.67",
            3,         "3",           "280.12",   "341.63",     "38.61",       "13.67",
            4,         "4",           "280.12",   "341.63",     "38.61",       "13.67",
            5,         "5",           "280.12",   "341.63",     "38.61",       "13.67",
          )

          totals = mk_totals(order_rows)

          accounts = [
            [ "ACH: FIRST NATIONAL BANK - *********5298", 10 ],
            [ "ACH: RIVER VALLEY STATE BANK - *********0039", 11 ],
          ]

          m1 = {
            market_id: 1, 
            market_name: "Springfield Demo Market",
            order_rows: order_rows,
            payable_accounts_for_select: accounts,
            market_totals: totals
          }

          order_rows2 = mk_order_rows({order_number_prefix: "LO-14-SPRINGFIELD-000004"},
            :order_id, :order_number, :owed,      :order_total, :delivery_fee, :market_fee,
            1,         "1",           "280.12",   "341.63",     "38.61",       "13.67",
            2,         "2",           "280.12",   "341.63",     "38.61",       "13.67",
            3,         "3",           "280.12",   "341.63",     "38.61",       "13.67",
            4,         "4",           "280.12",   "341.63",     "38.61",       "13.67",
            5,         "5",           "280.12",   "341.63",     "38.61",       "13.67",
          )

          totals2 = mk_totals(order_rows2)

          accounts2 = [
            [ "ACH: SOMETHING STATE BANK - *********7384", 20 ],
            [ "ACH: OTHER NATIONAL BANK - *********1265", 21 ],
          ]

          m2 = {
            market_id: 2, 
            market_name: "ABC Market",
            order_rows: order_rows2,
            payable_accounts_for_select: accounts2,
            market_totals: totals2
          }

          order_rows3 = mk_order_rows({order_number_prefix: "LO-14-ABC-000032"},
            :order_id, :order_number, :owed,      :order_total, :delivery_fee, :market_fee,
            3,         "3",           "280.12",   "341.63",     "38.61",       "13.67",
            4,         "4",           "280.12",   "341.63",     "38.61",       "13.67",
            5,         "5",           "280.12",   "341.63",     "38.61",       "13.67",
          )

          totals3 = mk_totals(order_rows3)

          accounts3 = []

          m3 = {
            market_id: 3, 
            market_name: "Someone Special Inc",
            order_rows: order_rows3,
            payable_accounts_for_select: accounts3,
            market_totals: totals3
          }

          market_section_list = [ 
            m1,
            m2,
            m3,
          ]

          return SchemaValidation.validate!([Financials::MarketPayments::Schema::MarketSection], market_section_list)
        end
      end
    end
  end
end
