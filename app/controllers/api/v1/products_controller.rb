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
        @start = params[:start] || 0

        products = available_products
          .offset(@start)
          .limit(50)
          .includes(:organization, :second_level_category, :prices, :unit)
          .uniq
        render :json => products.map {|p| output_hash(p)}
      end

      private

      def available_products
        current_delivery
          .object
          .delivery_schedule
          .products
          .with_available_inventory(current_delivery.deliver_on)
          .priced_for_market_and_buyer(current_market, current_organization)
          .order(:name)
      end

      def output_hash(product)
        prices = product.prices_for_market_and_organization(current_market, current_organization)
        formatted_prices = prices.map {|price| "#{number_to_currency(price.sale_price)} for #{price.min_quantity}+"}.join(', ')
        {
          :id=> product.id,
          :name=> product.name,
          :second_level_category_name => product.second_level_category.name,
          :seller_name => product.organization.name,
          :pricing => formatted_prices,
          :unit_with_description => product.unit_with_description(:plural)
        }
      end
    end
  end
end