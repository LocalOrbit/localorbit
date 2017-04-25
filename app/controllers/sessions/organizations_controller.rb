module Sessions
  class OrganizationsController < ApplicationController
    before_action :hide_admin_navigation

    def new
      if current_market.is_consignment_market?
        @organizations = current_user.managed_organizations_within_market(current_market).active.where(org_type: 'B').order(:name)
      else
        @organizations = current_user.managed_organizations_within_market(current_market).active.order(:name)
      end
      session.delete(:cart_id)
      session.delete(:current_organization_id)
      session.delete(:current_supplier_id)
      session.delete(:current_delivery_id)
      session.delete(:current_delivery_day)
    end

    def create
      if (org = current_user.managed_organizations.find_by(id: params[:org_id]))
        session[:current_organization_id] = org.id
        redirect_to redirect_to_url
      else
        flash[:alert] = 'Please select a buyer'
        new
        render :new
      end
    end
  end
end
