class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_market

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def render_404
    render file: Rails.root.join('public/404.html'), status: :not_found
  end

  def current_organization
    return nil unless current_user
    if current_user.managed_organizations.count > 1
      current_user.managed_organizations.find_by_id(session[:current_organization_id])
    else
      current_user.managed_organizations.first
    end
  end

  def current_market
    Market.find_by(subdomain: request.subdomain)
  end

  def current_organization
    # FIXME: Change this after we have organization selection.
    @current_organization ||= current_user.managed_organizations.first
  end
end
