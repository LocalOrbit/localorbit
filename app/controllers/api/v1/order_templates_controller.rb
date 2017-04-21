module Api
  module V1
    class OrderTemplatesController < ApplicationController
      before_action :require_selected_market
      before_action :check_access

      def index
        if current_user.market_manager?
          render json: {templates: OrderTemplate.where("market_id = ? AND buyer_id IS NULL", current_market.id).as_json({include: :items})}
        else
          render json: {templates: OrderTemplate.where("market_id = ? AND buyer_id = ?", current_market.id, current_organization.id).as_json({include: :items})}
        end

      end

      def destroy
        params.require(:id)
        OrderTemplate.where(market: current_market).find(params[:id]).destroy
        head :ok, content_type: "text/html"
      end

      def create
        cart = Cart.find(params[:cart_id])
        name = params[:name]
        template = nil
        if cart && name
          template = OrderTemplate.create_from_cart!(cart, name, current_user)
        end
        render json: {template: template.as_json, url: templates_path}
      end

      private

      def check_access
        if !Pundit.policy(current_user, :template)
          render(:file => File.join(Rails.root, 'public/404.html'), :status => 404, :layout => false)
        end
      end
    end
  end
end