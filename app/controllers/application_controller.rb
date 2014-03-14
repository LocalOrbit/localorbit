class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_market
  helper_method :current_organization

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def application_subdomain
    @@main_domain_subdomains = ActionDispatch::Http::URL.extract_subdomains(Figaro.env.domain, 1) unless defined?(@@main_domain_subdomains)
    (request.subdomains - @@main_domain_subdomains).last
  end

  def render_404
    render file: Rails.root.join('public/404.html'), status: :not_found
  end

  def current_organization
    #TODO: Memoize
    return nil unless current_user.present?

    if current_user.managed_organizations.count == 1
      session[:current_organization_id] = current_user.managed_organizations.first.id
    end

    current_user.managed_organizations.find_by(id: session[:current_organization_id])
  end

  def current_market
    @current_market ||= current_user.markets.find_by!(subdomain: application_subdomain)
  end

  def current_delivery
    return nil unless current_user.present?
    return nil unless current_market.present?
    return nil unless current_organization.present?
    return @current_delivery if defined?(@current_delivery)

    @current_delivery = Delivery.
      joins(:delivery_schedule).
      where('delivery_schedules.market_id = ? AND deliveries.cutoff_time > ?', current_market.id, Time.current).
      find_by(id: session[:current_delivery_id])
  end

  def hide_admin_navigation
    @hide_admin_nav = true
  end
end
