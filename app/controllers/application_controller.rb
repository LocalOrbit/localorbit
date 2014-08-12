class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :ensure_market_affiliation
  before_action :set_timezone

  helper_method :current_market
  helper_method :current_organization
  helper_method :current_cart
  helper_method :current_delivery
  helper_method :redirect_to_url
  helper_method :signed_in_root_path

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  private

  def signed_in_root_path(resource)
    return root_path unless resource
    extra = on_main_domain? && resource.markets.any? ? {host: resource.markets.first.domain} : {}
    if resource.buyer_only?
      products_url(extra)
    else
      dashboard_url(extra)
    end
  end

  def after_update_path_for(_)
    dashboard_path
  end

  def render_404
    render file: Rails.root.join("public/404.html"), status: :not_found
  end

  def current_organization
    if @current_organization && @current_organization.all_markets.include?(current_market)
      return @current_organization
    end

    potential = if current_user.managed_organizations.count == 1
      current_user.managed_organizations.first
    elsif session[:current_organization_id]
      current_user.managed_organizations.find_by(id: session[:current_organization_id])
    end

    @current_organization = potential if potential && potential.all_markets.include?(current_market)
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

  def market_for_current_subdomain(scope=Market)
    subdomain = request.subdomains(Figaro.env.domain.count(".")).first
    scope.find_by(subdomain: SimpleIDN.to_unicode(subdomain))
  end

  def require_selected_market
    return if current_market

    if current_user.markets.size == 1
      redirect_to url_for(host: current_user.markets.first.domain)
    else
      render "shared/select_market"
    end
  end

  def on_main_domain?
    request.host == Figaro.env.domain || request.host == "app.#{Figaro.env.domain}"
  end

  def current_delivery
    return nil if current_market.blank? || current_organization.blank?

    if defined?(@current_delivery)
      @current_delivery
    else
      @current_delivery = find_or_build_current_delivery.try(:decorate)
    end
  end

  def find_or_build_current_delivery
    if selected = Delivery.current_selected(current_market, session[:current_delivery_id])
      selected
    elsif only_delivery = current_market.only_delivery
      session[:current_delivery_id] = only_delivery.id
      only_delivery
    end
  end

  def selected_organization_location
    @selected_organization_location ||=
      (session[:current_location] && current_organization.locations.visible.find_by(id: session[:current_location])) ||
      current_organization.shipping_location
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

    @current_cart ||= current_user.carts.includes(items: {product: :prices}).find_by(id: session[:cart_id]).try(:decorate)
  end

  def require_cart
    @current_cart = Cart.find_or_create_by!(user_id: current_user.id, organization_id: current_organization.id, market_id: current_market.id, delivery_id: current_delivery.id) do |c|
      c.location = selected_organization_location if current_delivery.requires_location?
    end.decorate
    session[:cart_id] = @current_cart.id
  end

  def require_organization_location
    return unless current_organization && current_organization.locations.visible.none?
    redirect_to [:new_admin, current_organization, :location], alert: "You must enter an address for this organization before you can shop"
  end

  def require_market_open
    render "shared/market_closed" if current_market.closed?
  end

  def require_current_organization
    return unless current_organization.nil?
    redirect_to new_sessions_organization_path(redirect_back_to: request.fullpath)
  end

  def require_current_delivery
    return unless current_delivery.nil? || (current_delivery.requires_location? && selected_organization_location.nil?)
    redirect_to new_sessions_deliveries_path(redirect_back_to: request.fullpath)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:name, :email]
    devise_parameter_sanitizer.for(:account_update).concat [:name]
  end

  def redirect_to_url
    params[:redirect_back_to] || [:products]
  end
end
