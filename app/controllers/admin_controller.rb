class AdminController < ApplicationController

  def update_organizations
    if !params[:market_id].empty?
      @organizations = Organization.joins(:market_organizations).where("market_id = ?", params[:market_id]).select("organizations.name, organizations.id").order("organizations.name").uniq
    else
      markets = current_user.markets
      @organizations = Organization.joins(:market_organizations).where("market_organizations.market_id in (?)", markets.map(&:id)).select("organizations.name, organizations.id").order("organizations.name").uniq
    end
    respond_to do |format|
      format.js { render '/shared/update_organizations' }
    end
  end

  protected

  def require_admin
    render_404 unless current_user.admin?
  end

  def require_admin_or_market_manager
    return if current_user.admin?
    return if current_user.managed_markets.any?
    render_404
  end

  def find_market
    @market = current_user.markets.find(params[:market_id])
  end

  def lookup_manageable_user
    @user = User.find(params[:id])
    render_404 unless current_user.can_manage_user?(@user) || (current_user.market_manager? && !Pundit.policy!(current_user, :all_supplier).index?)
  end

  def load_qb_session
    if Pundit.policy(current_user, :market_quickbooks) && !current_market.organization.qb_token.nil?
      session[:qb_token] = current_market.organization.qb_token.access_token
      session[:qb_secret] = current_market.organization.qb_token.access_secret
      session[:qb_realm_id] = current_market.organization.qb_token.realm_id
    end
  end
end
