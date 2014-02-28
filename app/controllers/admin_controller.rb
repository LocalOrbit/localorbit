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
end
