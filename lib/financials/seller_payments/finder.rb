module Financials
  module SellerPayments
    class Finder
      class << self
        include ::Financials::SellerPayments::Schema

        def payable_automate_orders(as_of:, seller_id: nil, order_id: nil)
          scope = Order.
            clean_payment_records.
            on_automate_plan.
            paid.
            used_lo_payment_processing.
            payable_to_automate_sellers(current_time: as_of, seller_organization_id: seller_id)

          if order_id != nil
            scope = scope.where(id: order_id)
          end

          scope
        end

        def find_payable_seller_orders(as_of:, seller_id: nil, order_id: nil)
          orders = payable_automate_orders(
            as_of: as_of, 
            seller_id: seller_id, 
            order_id: order_id
          ).preload(:items, :organization)

          # Preload seller organizations:
          seller_orgs = Organization.find(orders.map(&:seller_id).uniq).
            inject({}) { |h,org| h[org.id] = org; h } #indexed by their ids

          # Wrap Orders in SellerOrder presenters:
          orders.map do |order|
            SellerOrder.new(order, seller_orgs[order.seller_id])
          end
        end
        
        # Returns an Array of Financials::SellerPayments::Schema::SellerSection 
        def find_seller_payment_sections(as_of:, seller_id: nil, order_id: nil)
          seller_orders = find_payable_seller_orders(as_of: as_of, seller_id: seller_id, order_id: order_id)
          
          # Group by seller_id,market_id  # .... market_id really? is important?
          seller_sections = seller_orders.group_by(&:seller_id).map do |_, sos| 
            ::Financials::SellerPayments::Builder.build_seller_section( 
              seller_organization: sos.first.seller,
              seller_orders: sos
            )
          end.sort_by do |section|
            section[:seller_name]
          end

          return SchemaValidation.validate!([SellerSection], seller_sections)
        end
      end
    end
  end
end
