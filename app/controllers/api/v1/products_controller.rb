module Api
  module V1
    class ProductsController < ApplicationController
      include ActiveSupport::NumberHelper
      before_action :require_selected_market
      before_action :require_market_open
      before_action :require_current_organization
      before_action :require_organization_location
      before_action :require_current_delivery

      def index
        @offset = (params[:offset] || 0).to_i
        @limit = (params[:limit] || 30).to_i
        @query = (params[:query] || '').gsub(/\W+/, '+') || ''
        @category_ids = (params[:category_ids] || [])
        @seller_ids = (params[:seller_ids] || [])
        @sort_by = (params[:sort_by] || "top_level_category.name, general_products.name")
        @sort_by = (params[:sort_by] || "top_level_category.lft, second_level_category.lft, general_products.name")

        featured_promotion = current_market.featured_promotion(current_organization)
        products = filtered_available_products(@query, @category_ids, @seller_ids)
        sellers = {}
        page_of_products = products
                               .offset(@offset)
                               .limit(@limit)
                               .map { |p| format_general_product_for_catalog(p, sellers) }
        render :json => {
                   product_total: products.count(:all),
                   featured_promotion: { :details => featured_promotion, :product => format_general_product_for_catalog(featured_promotion.product.general_product, sellers) },
                   products: page_of_products,
                   sellers: sellers
               }
      end

      private

      def filtered_available_products(query, category_ids, seller_ids)
        p_sql = Product.connection.unprepared_statement do
          current_delivery
              .object
              .delivery_schedule
              .products
              .visible
              .with_available_inventory(current_delivery.deliver_on)
              .priced_for_market_and_buyer(current_market, current_organization)
              .with_visible_pricing
              .select(:general_product_id)
              .to_sql
        end

        GeneralProduct.joins("JOIN (#{p_sql}) p_child ON general_products.id=p_child.general_product_id
                              JOIN categories top_level_category ON general_products.top_level_category_id = top_level_category.id
                              JOIN categories second_level_category ON general_products.second_level_category_id = second_level_category.id
                              JOIN organizations supplier ON general_products.organization_id=supplier.id
                              JOIN market_organizations ON general_products.organization_id = market_organizations.organization_id
                              AND market_organizations.market_id = #{current_market.id}")
            .filter_by_name_or_category_or_supplier(query)
            .filter_by_categories(category_ids)
            .filter_by_suppliers(seller_ids)
            .filter_by_active_org
            .select("top_level_category.lft, top_level_category.name, second_level_category.lft, second_level_category.name, general_products.*")
            .order(@sort_by)
            .uniq
      end

      def format_general_product_for_catalog(general_product, sellers)
        general_product = general_product.decorate

        sellers[general_product.organization.id] ||= {
            :seller_name => general_product.organization.name,
            :who_story => general_product.organization.who_story,
            :how_story => general_product.organization.how_story,
            :location_label => general_product.location_label,
            :location_map_url => general_product.location_map(310, 225)
        }

        products = general_product.product.visible
                       .map { |product| format_product_for_catalog(product) }
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

      def format_product_for_catalog(product)
        product = product.decorate(context: {current_cart: current_cart})

        available_inventory = product.available_inventory(current_delivery.deliver_on)

        prices = product.prices_for_market_and_organization(current_market, current_organization).map { |price|
          format_price_for_catalog(price)
        }

        # TODO There's a brief window where prices and inventory may change after
        # the general products are found, but before the response is fully generated.
        # If all products become ineligible on a general product, it will appear in
        # the catalog without any prices or units available.
        if prices && prices.length > 0 && available_inventory && available_inventory > 0
          cart_item = product.cart_item.decorate

          {
              :id => product.id,
              :max_available => available_inventory,
              :min_available => product.minimum_quantity_for_purchase({market:current_market,organization:current_organization}),
              :unit => product.unit.plural,
              :unit_description => product.unit_plural,
              :prices => prices,
              :cart_item => cart_item.object,
              :cart_item_persisted => cart_item.persisted?,
              :cart_item_quantity => cart_item.quantity,
              :price_for_quantity => number_to_currency(cart_item.unit_price.sale_price),
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
