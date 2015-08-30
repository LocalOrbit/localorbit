module Api
  module V1
    class FiltersController < ApplicationController
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

        if(params[:parent_id] && params[:parent_id] === "suppliers")
          filters = current_market
            .organizations
            .where(can_sell: true, active: true)
        elsif(params[:parent_id])
          filters = Category
            .where("id in (#{secondary_subquery.to_sql})")
            .where(parent_id: params[:parent_id])
        else
          filters = Category.where("id in (#{top_level_subquery.to_sql})")
        end
        render :json => {filters: filters.order(:name).select(:name, :id)}
      end

      private

      def secondary_subquery
        Product
          .select(:second_level_category_id)
          .where(organization: current_market.organizations.select(:id).to_a)
          .uniq
      end

      def top_level_subquery
        Product
          .select(:top_level_category_id)
          .where(organization: current_market.organizations.select(:id).to_a)
          .uniq
      end
    end
  end
end