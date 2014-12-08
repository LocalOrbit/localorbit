module Financials
  module SellerPayments
    class Builder
      class << self
        include Financials::SellerPayments::Schema

        def build_seller_section(seller_organization:, seller_orders:)
          order_rows = seller_orders.map { |o| build_order_row(o) }
          seller_totals = crunch_totals(order_rows.map { |r| r[:order_totals] })
          accounts = seller_organization.
            bank_accounts.
            verified.
            creditable_bank_accounts.
            sort_by(&:display_name).
            map do |acct|
              [acct.display_name, acct.id]
            end

          seller_section = {
            seller_id: seller_organization.id,
            seller_name: seller_organization.name,
            payable_accounts_for_select: accounts,
            order_rows: order_rows,
            seller_totals: seller_totals
          }

          return valid(SellerSection, seller_section)
        end


        def build_order_totals(order_items)
          t = crunch_totals(order_items.map { |oi| order_item_to_totals(oi) })
          return valid(Totals, t)
        end

        def crunch_totals(totals_array)
          valid [Totals], totals_array

          keys = Totals.keys
          crunched = totals_array.inject(default_totals) do |total, t|
            keys.each do |k|
              total[k] += t[k]
            end
            total
          end
          return valid(Totals, crunched)
        end


        def order_item_to_totals(order_item)
          t = {
            gross_sales:              order_item.gross_total,
            net_sales:                order_item.seller_net_total,
            market_fees:              order_item.market_seller_fee,
            transaction_fees:         order_item.local_orbit_seller_fee,
            payment_processing_fees:  order_item.payment_seller_fee,
            discounts:                order_item.discount_seller
          }
          return valid(Totals, t)
        end

        def build_order_row(order)
          totals = build_order_totals(order.items)
          delivery_status = Orders::DeliveryStatusLogic.overall_status_for_order(order)
          nice_delivery_status = Orders::DeliveryStatusLogic.human_readable(delivery_status)

          order_row = {
            order_id: order.id,
            order_number: order.order_number,
            order_totals: totals,
            delivery_status: nice_delivery_status,
            buyer_payment_status: order.payment_status.to_s.titleize,
            seller_payment_status: get_seller_payment_status(order),
            payment_method: order.payment_method.to_s.titleize
          }
          return valid(OrderRow, order_row)
        end

        private

        def get_seller_payment_status(order)
          item_stati = order.items.map(&:seller_payment_status).uniq
          if item_stati.length == 1
            item_stati.first
          else
            "Unpaid"
          end
        end

        def valid(schema, object)
          SchemaValidation.validate!(schema,object)
        end

        def default_totals
          zero =  "0.0".to_d
          t = {
            gross_sales:             zero,
            net_sales:               zero,
            market_fees:             zero,
            transaction_fees:        zero,
            payment_processing_fees: zero,
            discounts:               zero,
          }

          return valid(Totals, t)
        end
      end
    end
  end
end
