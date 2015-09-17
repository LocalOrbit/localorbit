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
        @limit = (params[:limit] || 10).to_i
        @query = (params[:query] || '').gsub(/\W+/, '+') || ''
        @category_ids = (params[:category_ids] || [])
        @seller_ids = (params[:seller_ids] || [])

        products = filtered_available_products(@query, @category_ids, @seller_ids)
        sellers = {}
        page_of_products = products
                               .offset(@offset)
                               .limit(@limit)
                               .map { |p| format_general_product_for_catalog(p, sellers) }
        render :json => {
                   product_total: products.count(:all),
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
              .with_available_inventory(current_delivery.deliver_on)
              .priced_for_market_and_buyer(current_market, current_organization)
              .select(:general_product_id)
              .to_sql
        end

        GeneralProduct.joins("JOIN (#{p_sql}) p_child ON general_products.id=p_child.general_product_id")
            .filter_by_name(query)
            .filter_by_categories(category_ids)
            .filter_by_suppliers(seller_ids)
            .order(:name)
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

        products = general_product.product
                       .map { |product| format_product_for_catalog(product) }
                       .compact
                       .sort_by { |product_info| product_info["unit"] }

        {
            :id => general_product.id,
            :name => general_product.name,
            :seller_id => general_product.organization.id,
            :short_description => general_product.short_description,
            :long_description => general_product.long_description,
            :second_level_category_name => general_product.second_level_category.name,
            :image_url => get_image_url(general_product),
            :available => products
        }
      end

      def format_product_for_catalog(product)
        product = product.decorate(context: {current_cart: current_cart})

        prices = product.prices_for_market_and_organization(current_market, current_organization).map { |price|
          format_price_for_catalog(price)
        }

        if prices && prices.length > 0
          cart_item = product.cart_item.decorate

          {
              :id => product.id,
              :max_available => product.available_inventory(current_delivery.deliver_on),
              :unit => product.unit.plural,
              :unit_description => product.unit_description,
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
            :min_quantity => price.min_quantity
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
