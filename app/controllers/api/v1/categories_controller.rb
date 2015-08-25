module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :require_selected_market
      before_action :require_market_open

      def index
        # Note: ideally, we want to return the categories that have viable products for
        # sale, and only the categories that have viable products for sale.

        # Unfortunately, determining whether or not a product is for sale is an expensive
        # query that depends on a chain of many-to-many relationships and dynamic data.
        # (It depends on the user's current market and org, it depends on what prices
        # are available for a product, it depends on a product's lots, it depends on the
        # product's delivery schedule, etc.)

        # This is a compromise between accuracy and speed: all of the products listed for
        # a market, but without checking pricing and inventory data.

        categories = Category.where("id in (#{category_ids_subquery.to_sql})")
        if(params[:parent_id])
          categories = categories.where(parent_id: params[:parent_id])
        end
        render :json => {categories: categories.select(:name, :id)}
      end

      private

      def category_ids_subquery
        Product
          .select(:category_id)
          .where(organization: current_market.organizations.select(:id).to_a)
          .uniq
      end
    end
  end
end