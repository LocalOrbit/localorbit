require 'tabulator'
module Financials
  module SellerPayments
    class Faker
      class << self
        def mk_order_rows(opts={},*data)
          order_number_prefix = opts[:order_number_prefix] || "LO-14-ALLENMARKETPLACE-000003"
          Tabulator.tabulate(12, data) do |row|
            row[:order_number] = "#{order_number_prefix}#{row[:order_number]}"
            row[:order_totals] = {}
            [:net_sales, :gross_sales, :market_fees, :transaction_fees, :payment_processing_fees, :discounts].each do |k|
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
            net_sales:               hsum[order_rows, :net_sales],
            gross_sales:             hsum[order_rows, :gross_sales],
            market_fees:             hsum[order_rows, :market_fees],
            transaction_fees:        hsum[order_rows, :transaction_fees],
            payment_processing_fees: hsum[order_rows, :payment_processing_fees],
            discounts:               hsum[order_rows, :discounts]
          }
        end

        def mk_seller_sections
          order_rows = mk_order_rows({},
            :order_id, :order_number, :net_sales, :gross_sales, :market_fees, :transaction_fees, :payment_processing_fees, :discounts, :delivery_status, :buyer_payment_status, :seller_payment_status, :payment_method,
            1,         "1",           "280.12",   "341.63",     "38.61",      "13.67",           "9.23",                   "0",        "Delivered",      "Paid",                "Unpaid",               "Credit Card",
            2,         "2",           "280.12",   "341.63",     "38.61",      "13.67",           "9.23",                   "0",        "Delivered",      "Paid",                "Unpaid",               "Credit Card",
            3,         "3",           "280.12",   "341.63",     "38.61",      "13.67",           "9.23",                   "0",        "Delivered",      "Paid",                "Unpaid",               "Credit Card",
            4,         "4",           "280.12",   "341.63",     "38.61",      "13.67",           "9.23",                   "0",        "Delivered",      "Paid",                "Unpaid",               "Credit Card",
            5,         "5",           "280.12",   "341.63",     "38.61",      "13.67",           "9.23",                   "0",        "Delivered",      "Paid",                "Unpaid",               "Credit Card",
          )

          totals = mk_totals(order_rows)

          accounts = [
            [ "ACH: FIRST NATIONAL BANK - *********5298", 10 ],
            [ "ACH: RIVER VALLEY STATE BANK - *********0039", 11 ],
          ]

          s1 = {
            seller_id: 1, 
            seller_name: "CBI's Giving Tree Farm",
            order_rows: order_rows,
            payable_accounts_for_select: accounts,
            seller_totals: totals
          }

          order_rows2 = mk_order_rows({order_number_prefix: "LO-14-SPRINGFIELD-000004"},
            :order_id, :order_number, :net_sales, :gross_sales, :market_fees, :transaction_fees, :payment_processing_fees, :discounts, :delivery_status, :buyer_payment_status, :seller_payment_status, :payment_method,
            9,         "9",           "106.3",    "126.30",     "10.00",      "00.00",           "0.00",                   "0",        "Delivered",      "Paid",                "Unpaid",               "ACH",
            10,        "10",          "106.3",    "126.30",     "10.00",      "00.00",           "0.00",                   "0",        "Delivered",      "Paid",                "Unpaid",               "ACH",
            11,        "11",          "106.3",    "126.30",     "10.00",      "00.00",           "0.00",                   "0",        "Delivered",      "Paid",                "Unpaid",               "ACH",
          )

          totals2 = mk_totals(order_rows2)

          accounts2 = [
            [ "ACH: SOMETHING STATE BANK - *********7384", 20 ],
            [ "ACH: OTHER NATIONAL BANK - *********1265", 21 ],
          ]

          s2 = {
            seller_id: 2, 
            seller_name: "Boetcher Farm",
            order_rows: order_rows2,
            payable_accounts_for_select: accounts2,
            seller_totals: totals2
          }

          order_rows3 = mk_order_rows({order_number_prefix: "LO-14-ABC-000032"},
            :order_id, :order_number, :net_sales, :gross_sales, :market_fees, :transaction_fees, :payment_processing_fees, :discounts, :delivery_status, :buyer_payment_status, :seller_payment_status, :payment_method,
            20,        "20",          "120.23",   "120.23",     "00.00",      "00.00",           "0.00",                   "0",        "Delivered",      "Paid",                "Unpaid",               "Credit Card",
            21,        "21",          "136.87",   "136.87",     "00.00",      "00.00",           "0.00",                   "0",        "Delivered",      "Paid",                "Unpaid",               "Credit Card",
          )

          totals3 = mk_totals(order_rows3)

          accounts3 = []

          s3 = {
            seller_id: 3, 
            seller_name: "Someone Special Inc",
            order_rows: order_rows3,
            payable_accounts_for_select: accounts3,
            seller_totals: totals3
          }

          seller_section_list = [ 
            s1,
            s2,
            s3,
          ]

          return SchemaValidation.validate!([Financials::SellerPayments::Schema::SellerSection], seller_section_list)
        end
      end
    end
  end
end
