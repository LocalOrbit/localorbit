module Api
  module V1
    class SaleableProductsController < ProductsController

      private

      def filtered_available_products(query, category_ids, seller_ids, order)
        catalog_products = cross_sold_products = Product.connection.unprepared_statement do
          Product.joins(organization: [market_organizations: [:market]])
            .where("markets.id = ?", current_market.id)
            .with_available_so_inventory(current_delivery.deliver_on)
            .visible
            .select(:id, :general_product_id)
            .to_sql
        end

        catalog_products2 = cross_sold_products2 = Product.connection.unprepared_statement do
          Product.joins(organization: [market_organizations: [:market]])
              .where("markets.id = ?", current_market.id)
              .with_pending_so_inventory(current_delivery.deliver_on)
              .visible
              .select(:id, :general_product_id)
              .to_sql
        end

        cp = "#{catalog_products} UNION #{catalog_products2} UNION
        SELECT products.id, products.general_product_id
        FROM products
        INNER JOIN organizations ON organizations.id = products.organization_id
        INNER JOIN market_organizations ON market_organizations.organization_id = organizations.id
        INNER JOIN markets ON markets.id = market_organizations.market_id
        INNER JOIN consignment_transactions ON consignment_transactions.product_id = products.id AND consignment_transactions.market_id = markets.id AND consignment_transactions.transaction_type = 'PO' AND consignment_transactions.lot_id IS NULL AND consignment_transactions.deleted_at IS NULL
        INNER JOIN orders ON consignment_transactions.order_id = orders.id AND orders.delivery_status in ('pending','partially delivered')
        WHERE markets.id = #{current_market.id} AND products.deleted_at IS NULL"

        gp = GeneralProduct.joins("JOIN (#{cp}) p_child
              ON general_products.id=p_child.general_product_id
              JOIN categories top_level_category ON general_products.top_level_category_id = top_level_category.id
              JOIN categories second_level_category ON general_products.second_level_category_id = second_level_category.id
              JOIN organizations supplier ON general_products.organization_id=supplier.id
              LEFT JOIN market_organizations ON general_products.organization_id = market_organizations.organization_id
              AND market_organizations.market_id = #{current_market.id}")
                 .filter_by_name_or_category_or_supplier(query)
                 .filter_by_categories(category_ids)
                 .filter_by_suppliers(seller_ids)
                 .filter_by_active_org
                 .select("top_level_category.lft, top_level_category.name, second_level_category.lft, second_level_category.name, general_products.*")
                 .order("general_products.name")
                 .uniq
      end

    end
  end
end
