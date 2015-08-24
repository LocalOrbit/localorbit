module Api
  module V1
    class SellersController < ApplicationController
      before_action :require_selected_market
      before_action :require_market_open

      def index
        sellers = current_market
          .organizations
          .select(:name, :id)
          .where(can_sell: true, active: true)
          .order(:name)
        render :json => {sellers: sellers}
      end
    end
  end
end