module Api
  module V1
    class PurchaseableProductsController < ProductsController

      private

      def filtered_available_products(query, category_ids, seller_ids, order)
        catalog_products = cross_sold_products = Product.connection.unprepared_statement do
          Product.joins(organization: [market_organizations: [:market]])
              .where("markets.id = ?", current_market.id)
              .visible
              .select(:id, :general_product_id)
              .to_sql
        end

        # KXM GC: Disable cross selling products for now.
        # Once re-enabled you can delete the double assignment in catalog_products above...

        # cross_sold_products = Product.
        #   cross_selling_list_items(current_market.id).
        #   visible.
        #   with_available_inventory(current_delivery.deliver_on).
        #   priced_for_market_and_buyer(current_market, current_organization).
        #   with_visible_pricing.
        #   select(:id, :general_product_id).
        #   to_sql

        gp = GeneralProduct.joins("JOIN (#{catalog_products}) p_child
              ON general_products.id=p_child.general_product_id
              JOIN categories top_level_category ON general_products.top_level_category_id = top_level_category.id
              JOIN categories second_level_category ON general_products.second_level_category_id = second_level_category.id
              JOIN organizations supplier ON general_products.organization_id=supplier.id")
                 .filter_by_current_order(order)
                 .filter_by_name_or_category_or_supplier(query)
                 .filter_by_categories(category_ids)
                 .filter_by_suppliers(seller_ids)
                 .select("top_level_category.lft, top_level_category.name, second_level_category.lft, second_level_category.name, general_products.*")
                 .order("general_products.name")
                 .uniq
      end


    end
  end
end
