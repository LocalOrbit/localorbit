class AdminController < ApplicationController
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
    render_404 unless current_user.can_manage_user?(@user)
  end
end
