module Api
  module V1
    class ProductsController < ApplicationController
      include ActiveSupport::NumberHelper
      before_action :set_order_id
      before_action :require_selected_market
      before_action :require_market_open
      before_action :require_current_organization
      before_action :require_organization_location
      before_action :require_current_delivery
      before_action :require_cart

      def index
        @offset = (params[:offset] || 0).to_i
        @limit = (params[:limit] || 30).to_i
        @query = (params[:query] || '').gsub(/\W+/, '+') || ''
        @category_ids = (params[:category_ids] || [])
        @seller_ids = (params[:seller_ids] || [])
        @sort_by = (params[:sort_by] || "top_level_category.lft, second_level_category.lft, general_products.name")
        order = !session[:order_id].nil? ? Order.find(session[:order_id]) : nil
        order_type = session[:order_type].present? ? session[:order_type] : nil

        if order
          featured_promotion = @order.market.featured_promotion(@order.organization, current_delivery)
        else
          featured_promotion = current_market.featured_promotion(current_organization, current_delivery)
        end

        if current_market.try(:is_consignment_market?) && order_type == 'purchase'
          products = filtered_available_po_consignment_products(@query, @category_ids, @seller_ids, @order)
        elsif current_market.try(:is_consignment_market?) && order_type == 'sales'
          products = filtered_available_so_consignment_products(@query, @category_ids, @seller_ids, @order)
        else
          products = filtered_available_products(@query, @category_ids, @seller_ids, @order)
        end

        sellers = {}
        page_of_products = products
                               .offset(@offset)
                               .limit(@limit)
                               .map { |p| format_general_product_for_catalog(p, sellers, @order) }
        render :json => {
                   product_total: products.count(:all),
                   featured_promotion: { :details => featured_promotion, :product => featured_promotion ? format_general_product_for_catalog(featured_promotion.product.general_product, sellers, @order) : nil },
                   products: page_of_products,
                   sellers: sellers
               }
      end

      private

      def filtered_available_products(query, category_ids, seller_ids, order)
        catalog_products = Product.connection.unprepared_statement do
          current_delivery
              .object
              .delivery_schedule
              .products
              .visible
              .with_available_inventory(current_delivery.deliver_on, current_market.id, current_organization.id)
              .priced_for_market_and_buyer(current_market, current_organization)
              .with_visible_pricing
              .select(:id, :general_product_id)
              .to_sql
        end

        cross_sold_products = Product.
          cross_selling_list_items(current_market.id).
          visible.
          with_available_inventory(current_delivery.deliver_on).
          priced_for_market_and_buyer(current_market, current_organization).
          with_visible_pricing.
          select(:id, :general_product_id).
          to_sql

        gp = GeneralProduct.joins("JOIN (#{catalog_products} UNION #{cross_sold_products}) p_child
              ON general_products.id=p_child.general_product_id
              JOIN categories top_level_category ON general_products.top_level_category_id = top_level_category.id
              JOIN categories second_level_category ON general_products.second_level_category_id = second_level_category.id
              JOIN organizations supplier ON general_products.organization_id=supplier.id
              LEFT JOIN market_organizations ON general_products.organization_id = market_organizations.organization_id
              AND market_organizations.market_id = #{current_market.id}")
            .filter_by_current_order(order)
            .filter_by_name_or_category_or_supplier(query)
            .filter_by_categories(category_ids)
            .filter_by_suppliers(seller_ids)
            .filter_by_active_org
            .select("top_level_category.lft, top_level_category.name, second_level_category.lft, second_level_category.name, general_products.*")
            .order(@sort_by)
            .uniq
      end

      def filtered_available_po_consignment_products(query, category_ids, seller_ids, order)
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
                 .order(@sort_by)
                 .uniq
      end

      def filtered_available_so_consignment_products(query, category_ids, seller_ids, order)
        catalog_products = cross_sold_products = Product.connection.unprepared_statement do
          Product.joins(organization: [market_organizations: [:market]])
            .where("markets.id = ?", current_market.id)
            .visible
            .select(:id, :general_product_id)
            .to_sql
          end

        gp = GeneralProduct.joins("JOIN (#{catalog_products}) p_child
              ON general_products.id=p_child.general_product_id
              JOIN categories top_level_category ON general_products.top_level_category_id = top_level_category.id
              JOIN categories second_level_category ON general_products.second_level_category_id = second_level_category.id
              JOIN organizations supplier ON general_products.organization_id=supplier.id
              LEFT JOIN market_organizations ON general_products.organization_id = market_organizations.organization_id
              AND market_organizations.market_id = #{current_market.id}")
                 .filter_by_current_order(order)
                 .filter_by_name_or_category_or_supplier(query)
                 .filter_by_categories(category_ids)
                 .filter_by_suppliers(seller_ids)
                 .filter_by_active_org
                 .select("top_level_category.lft, top_level_category.name, second_level_category.lft, second_level_category.name, general_products.*")
                 .order(@sort_by)
                 .uniq
      end

      def format_general_product_for_catalog(general_product, sellers, order)
        general_product = general_product.decorate

        sellers[general_product.organization.id] ||= {
            :seller_name => general_product.organization.name,
            :who_story => general_product.organization.who_story,
            :how_story => general_product.organization.how_story,
            :location_label => general_product.location_label,
            :location_map_url => general_product.location_map(310, 225)
        }

        products = general_product.product.visible
                       .map { |product| format_product_for_catalog(product, order) }
                       .compact
                       .sort { |a, b| a[:unit] <=> b[:unit] }

        {
            :id => general_product.id,
            :name => general_product.name,
            :seller_id => general_product.organization.id,
            :short_description => general_product.short_description,
            :long_description => general_product.long_description,
            :top_level_category_name => general_product.top_level_category.name,
            :second_level_category_name => general_product.second_level_category.name,
            :image_url => get_image_url(general_product),
            :available => products
        }
      end

      def format_product_for_catalog(product, order)
        product = product.decorate(context: {current_cart: current_cart, order: order} )

        available_inventory = product.available_inventory(current_delivery.deliver_on, current_market.id, current_organization.id)

        prices = Orders::UnitPriceLogic.prices(product, current_market, current_organization, current_market.add_item_pricing && order ? order.created_at : Time.current.end_of_minute).map { |price| format_price_for_catalog(price)}

        lots = nil
        committed = nil

        if current_market.is_consignment_market?
          lots = Lot.where(product_id: product.id).where("quantity > 0 AND number IS NOT NULL")
                     .select("id, quantity, number, (SELECT TO_CHAR(delivery_date, 'MM/DD/YYYY') FROM consignment_transactions WHERE lot_id = lots.id AND transaction_type = 'PO') delivery_date, 'available'::text AS status")
          #ct = ConsignmentTransaction.joins("LEFT JOIN (#{lots}) l_child
          #ON consignment_transactions.lot_id = l_child.id")
          #.select()

          awaiting_delivery = Order.joins(:items).where("orders.order_type = 'purchase' AND order_items.delivery_status = 'pending' AND orders.market_id = ? AND order_items.product_id = ?", current_market.id, product.id).select("null AS id, trunc(order_items.quantity) AS quantity, '' AS number, 'awaiting_delivery'::text AS status")
          awaiting_delivery_qty = ConsignmentTransaction.where("transaction_type = 'PO' AND lot_id IS NULL AND market_id = ? AND product_id = ?", current_market.id, product.id).sum(:quantity)
          awaiting_ordered_qty = ConsignmentTransaction.where("transaction_type = 'SO' AND lot_id IS NULL AND market_id = ? AND product_id = ?", current_market.id, product.id).sum(:quantity)

          awaiting_delivery = ConsignmentTransaction
            .joins("JOIN orders ON consignment_transactions.order_id = orders.id")
            .where("orders.delivery_status = 'pending' AND consignment_transactions.transaction_type = 'PO' AND consignment_transactions.lot_id IS NULL AND consignment_transactions.market_id = ? AND consignment_transactions.product_id = ?", current_market.id, product.id).select("null AS id, #{awaiting_delivery_qty - awaiting_ordered_qty} AS quantity, '' AS number, '' AS delivery_date, 'awaiting_delivery'::text AS status")
          committed = Order.joins(:organization, items: [lots: [:lot]]).so_orders.where("order_items.delivery_status = 'pending' AND orders.market_id = ? AND order_items.product_id = ?", current_market.id, product.id).select("order_items.product_id AS id, order_item_lots.lot_id, lots.number, organizations.name AS buyer_name, trunc(order_items.quantity) AS quantity, order_items.unit_price AS sale_price, order_items.net_price")
          lots = lots + awaiting_delivery
        end

        # TODO There's a brief window where prices and inventory may change after
        # the general products are found, but before the response is fully generated.
        # If all products become ineligible on a general product, it will appear in
        # the catalog without any prices or units available.
        if current_market.is_consignment_market? || (prices && prices.length > 0 && available_inventory && available_inventory > 0 && (!product.cart_item.nil?))
          cart_item = product.cart_item.decorate

          {
              :id => product.id,
              :max_available => available_inventory,
              :min_available => product.minimum_quantity_for_purchase({market: current_market, organization: current_organization}),
              :unit => product.unit.plural,
              :unit_description => product.unit_plural,
              :prices => prices,
              :lots => lots,
              :committed => committed,
              :cart_item => cart_item.object,
              :cart_item_persisted => cart_item.persisted?,
              :cart_item_quantity => cart_item.quantity,
              :price_for_quantity => number_to_currency(cart_item.unit_sale_price),
              :total_price => cart_item.display_total_price
          }
        else
          nil
        end
      end

      def format_price_for_catalog(price)
        price = price.decorate

        {
            :sale_price => number_to_currency(price.sale_price),
            :min_quantity => price.min_quantity,
            :organization_id => price.organization_id
        }
      end

      def get_image_url(product)
        if product.thumb_stored?
          view_context.image_url(product.thumb.url)
        elsif product.image_stored?
          view_context.image_url(product.image.thumb("150x150").url)
        else
          view_context.image_url('default-product-image.png')
        end
      end
    end
  end
end
