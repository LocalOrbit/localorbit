module Financials
  module OrderItemFeeCalculator
    class << self

      def market_fee_paid_by_seller(market:, order_item:)
        if market.nil? and !order_item.nil?
          market = order_item.order.market
        end # see below

        category_fee = order_item.product.category.category_fees.where(market_id: market.id)

        if order_item.category_fee_pct > 0
          rate = order_item.category_fee_pct
        elsif category_fee.first.fee_pct > 0
          rate = category_fee.first.fee/100
        elsif order_item.product_fee_pct > 0
          rate = order_item.product_fee_pct / 100
        else
          if order_item.order.market_seller_fee_pct.nil? #
            rate = market.market_seller_fee / 100
          else
            rate = order_item.order.market_seller_fee_pct / 100
          end
        end

        return round(rate * (order_item.gross_total - order_item.discount_seller))
      end
      
      def local_orbit_fee_paid_by_seller(market:, order_item:)
        if market.nil? and !order_item.nil?
          market = order_item.order.market
        end # add to take care of calling this separately on an order item -- is this a problem? jzc 2016-02-18
        rate = market.local_orbit_seller_fee / 100
        # TODO: IS THIS RIGHT?  Really discount the gross total by both seller and market share of the discount? This was how it was originally in StoreOrderFees.  crosby 2015-06-02
        return round(rate * (order_item.gross_total - order_item.discount_market - order_item.discount_seller))

      end

      def local_orbit_fee_paid_by_market(market:, order_item:)
        if market.nil? and !order_item.nil?
          market = order_item.order.market
        end # see above
        rate = market.local_orbit_market_fee / 100
        # TODO: IS THIS RIGHT?  Really discount the gross total by both seller and market share of the discount? This was how it was originally in StoreOrderFees.  crosby 2015-06-02
        return round(rate * (order_item.gross_total - order_item.discount_market - order_item.discount_seller))
      end

      private
      def round(dec)
        dec.round(2)
      end
    end
  end
end

