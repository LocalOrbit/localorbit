class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :ensure_market_affiliation
  before_action :set_timezone

  helper_method :current_market
  helper_method :current_organization
  helper_method :current_cart
  helper_method :current_location
  helper_method :current_delivery

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  private

  def after_sign_in_path_for(resource)
    extra = on_main_domain? && current_user.markets.any? ? {host: current_user.markets.first.domain} : {}
    if current_user.buyer_only?
      products_url(extra)
    else
      dashboard_url(extra)
    end
  end

  def after_update_path_for(resource)
    dashboard_path
  end

  def render_404
    render file: Rails.root.join('public/404.html'), status: :not_found
  end

  def current_organization
    return @current_organization if defined?(@current_organization)

    @current_organization = if current_user.managed_organizations.count == 1
      current_user.managed_organizations.first
    else
      current_user.managed_organizations.find_by(id: session[:current_organization_id])
    end
  end

  def current_location
    current_organization.locations.visible.find_by(id: session[:current_location]) || current_delivery.delivery_schedule.buyer_pickup_location
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
    subdomain = request.subdomains(Figaro.env.domain.count('.')).first
    scope.find_by(subdomain: SimpleIDN.to_unicode(subdomain))
  end

  def require_selected_market
    return if current_market

    if current_user.markets.size == 1
      redirect_to url_for(host: current_user.markets.first.domain)
    else
      render 'shared/select_market'
    end
  end

  def on_main_domain?
    request.host == Figaro.env.domain || request.host == "app.#{Figaro.env.domain}"
  end

  def current_delivery
    return nil unless current_market.present?
    return nil unless current_organization.present?
    return @current_delivery if defined?(@current_delivery)

    @current_delivery = find_or_build_current_delivery
    @current_delivery = @current_delivery.decorate(context: {current_organization: current_organization, location_id: session[:current_location]}) if @current_delivery
  end

  def find_or_build_current_delivery
    if session[:current_delivery_id]
      Delivery.upcoming.for_market(current_market).
        find_by(id: session[:current_delivery_id])
    elsif current_market.delivery_schedules.visible.count == 1
      current_market.delivery_schedules.visible.first.next_delivery.tap do |delivery|
        session[:current_delivery_id] = delivery.id
        if delivery.requires_location?
          session[:current_location] = current_organization.shipping_location.try(:id)
        end
      end
    end
  end

  def set_timezone
    Time.zone = current_market.timezone if current_market
  end

  def hide_admin_navigation
    @hide_admin_nav = true
  end

  def current_cart
    return nil unless session[:cart_id]
    return nil unless current_market.present?
    return nil unless current_organization.present?
    return nil unless current_delivery

    @current_cart ||= current_organization.carts.find_by(id: session[:cart_id])
  end

  def require_cart
    @current_cart = Cart.find_or_create_by!(organization_id: current_organization.id, market_id: current_market.id, delivery_id: current_delivery.id) do |c|
      c.location_id = current_location.id if current_delivery.requires_location?
    end
    session[:cart_id] = @current_cart.id
  end

  def require_organization_location
    if current_organization && current_organization.locations.visible.none?
      redirect_to [:new_admin, current_organization, :location], alert: "You must enter an address for this organization before you can shop"
    end
  end

  def require_current_organization
    if current_organization.nil?
      redirect_to new_sessions_organization_path(redirect_back_to: request.fullpath), alert: "You must first select an organization"
    end
  end

  def require_current_delivery
    if current_delivery.nil?
      redirect_to new_sessions_delivery_path(redirect_back_to: request.fullpath)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:name, :email]
    devise_parameter_sanitizer.for(:account_update).concat [:name]
  end
end
