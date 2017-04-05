module Sessions
  class SuppliersController < ApplicationController
    before_action :hide_admin_navigation

    def new
      @suppliers = current_market.suppliers.order(:name)
      session.delete(:cart_id)
      session.delete(:current_supplier_id)
      session.delete(:current_delivery_id)
      session.delete(:current_delivery_day)
    end

    def create
      if (org = current_market.suppliers.find_by(id: params[:org_id]))
        session[:current_supplier_id] = org.id
        redirect_to redirect_to_url
      else
        flash[:alert] = "Please select a supplier"
        new
        render :new
      end
    end
  end
end
