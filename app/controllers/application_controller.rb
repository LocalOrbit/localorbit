class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :ensure_market_affiliation
  before_action :set_timezone

  helper_method :current_market
  helper_method :current_organization
  helper_method :current_cart

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  private

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def render_404
    render file: Rails.root.join('public/404.html'), status: :not_found
  end

  def current_organization
    #TODO: Memoize

    if current_user.managed_organizations.count == 1
      session[:current_organization_id] = current_user.managed_organizations.first.id
    end

    current_user.managed_organizations.find_by(id: session[:current_organization_id])
  end

  def current_location
    Location.find_by(id: session[:current_location]) || current_delivery.delivery_schedule.buyer_pickup_location
  end

  def current_market
    @current_market ||= market_for_current_subdomain
  end

  # a before_action to ensure the current_user is affiliated with the market in
  # some capacity. 404 if not.
  def ensure_market_affiliation
    return if current_user.admin?
    if current_market.nil? || current_market != market_for_current_subdomain(current_user.markets)
      render_404
    end
  end

  def market_for_current_subdomain(scope = Market)
    subdomain = request.subdomains(Figaro.env.domain.count('.'))
    scope.find_by(subdomain: subdomain)
  end

  def current_delivery
    return nil unless current_market.present?
    return nil unless current_organization.present?
    return @current_delivery if defined?(@current_delivery)

    @current_delivery = Delivery.
      joins(:delivery_schedule).
      where('delivery_schedules.market_id = ? AND deliveries.cutoff_time > ?', current_market.id, Time.current).
      find_by(id: session[:current_delivery_id])
  end

  def set_timezone
    Time.zone = current_market.timezone if current_market
  end

  def hide_admin_navigation
    @hide_admin_nav = true
  end
  def current_cart
    return nil unless current_market.present?
    return nil unless current_organization.present?
    current_organization.carts.find_by(id: session[:cart_id])
  end

end
