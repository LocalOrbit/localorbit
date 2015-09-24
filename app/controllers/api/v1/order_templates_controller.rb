module Api
  module V1
    class OrderTemplatesController < ApplicationController
      before_action :require_selected_market
      before_action :check_access

      def index
        render json: {templates: OrderTemplate.where(market: current_market).as_json({include: :items})}
      end

      def destroy
        params.require(:id)
        OrderTemplate.where(market: current_market).find(params[:id]).destroy
        head :ok, content_type: "text/html"
      end

      def create
        cart = Cart.find(params[:cart_id])
        name = params[:name]
        if(cart && name)
          template = OrderTemplate.create_from_cart!(cart, name)
        end
        render json: {template: template.as_json, url: templates_path}
      end

      private

      def check_access
        if !FeatureAccess.order_templates?(market: current_market)
          render(:file => File.join(Rails.root, 'public/404.html'), :status => 404, :layout => false)
        end
      end
    end
  end
end