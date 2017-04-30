class ApplicationController < ActionController::Base
  include EventTracker

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :masquerade_user!
  before_action :authenticate_user!
  before_action :ensure_user_not_suspended
  before_action :ensure_market_affiliation
  before_action :ensure_active_organization

  before_action :set_timezone
  before_action :set_intercom_attributes

  helper_method :current_market
  helper_method :current_organization
  helper_method :current_cart
  helper_method :current_delivery
  helper_method :redirect_to_url
  helper_method :signed_in_root_path
  
  after_filter :cors_auth

  # Includes Authorization mechanism
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :render_404

  # Enforces access right checks for individuals resources
  #after_filter :verify_authorized, :except => :index

  # Enforces access right checks for collections
  #after_filter :verify_policy_scoped, :only => :index

  def cors_auth
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def track_event(event, metadata={})
    EventTracker.track_event_for_user current_user, event, metadata if current_user
  end

  private

  def signed_in_root_path(user)
    return root_path unless user
    extra = on_main_domain? && user.default_market ? {host: user.default_market.domain} : {}
    if user.buyer_only?
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
    if session[:order_id] # We're adding to an order, so use the market from the order
      @current_organization = Order.find(session[:order_id]).organization
      return @current_organization
    end

    return current_market.organization if current_market.try(:is_consignment_market?) && session[:order_type] == 'purchase'

    if @current_organization && (@last_organization_market == current_market || @current_organization.all_markets.include?(current_market))
      @last_organization_market = current_market
      return @current_organization
    end

    @last_organization_market = current_market
    @current_organization = find_current_organization
  end

  def current_supplier
    if session[:current_supplier_id]
      @current_supplier = current_market.suppliers.find_by(id: session[:current_supplier_id])
      return @current_supplier
    end
  end

  def find_current_organization
    return nil unless current_market
    return nil unless current_user

    current_user.managed_organizations_within_market(current_market)
    organization = if current_user.managed_organizations.count == 1
      current_user.managed_organizations.first
    elsif session[:current_organization_id]
      current_user.managed_organizations.find_by(id: session[:current_organization_id])
    end

    organization if organization && organization.all_markets.include?(current_market)
  end

  def current_market
    if session[:order_id] # We're adding to an order, so use the market from the order
      @current_market = Order.find(session[:order_id]).market
    else
      @current_market = market_for_current_subdomain
    end
  end

  def current_plan
    @current_plan ||= current_organization.plan.name
  end

  # a before_action to ensure the current_user is affiliated with the market in
  # some capacity. 404 if not.
  def ensure_market_affiliation
    return if current_user.admin?
    if (current_market.nil? || current_market != market_for_current_subdomain(current_user.markets)) && session[:order_id].nil?
      return render_404
    end

    unless current_market.active?
      render file: Rails.root.join("public/market_disabled.html"), status: :forbidden
    end
  end

  def ensure_allow_signups
    return if current_market.allow_signups || current_user.admin?
    render file: Rails.root.join("public/signups_disabled.html"), status: :forbidden
  end

  def ensure_active_organization
    return if current_user.nil?
    return if current_user.admin? || current_user.can_manage_market?(market_for_current_subdomain)
    if current_user.organizations.active.empty?
      render file: Rails.root.join("public/organization_disabled.html"), status: :forbidden
    end
  end

  def ensure_user_not_suspended
    return if current_user.nil?
    return if current_user.admin? || current_user.can_manage_market?(market_for_current_subdomain)

    if current_user.suspended_from_all_orgs?(current_market)
      render file: Rails.root.join("public/user_suspended.html"), status: :forbidden
    end
  end

  def market_for_current_subdomain(scope=Market)
    subdomain = request.subdomains(Figaro.env.domain.count(".")).first
    scope.find_by(subdomain: SimpleIDN.to_unicode(subdomain))
  end

  def require_selected_market
    return if current_market || session[:order_id]

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
    return nil if (current_market.blank? || current_organization.blank?) && session[:order_id].nil?

    if session[:order_id] # We're adding an item to an order, so use the delivery of the order
      @current_delivery = Order.find(session[:order_id]).delivery.decorate
    end

    if defined?(@current_delivery)
      @current_delivery
    else
      @current_delivery = find_or_build_current_delivery.try(:decorate)
    end
  end

  def find_or_build_current_delivery
    if session[:current_delivery_day]
      delivery_day = DateTime.parse(session[:current_delivery_day])
      delivery = Delivery.find(session[:current_delivery_id])
      if not delivery.buyer_deliver_on.day == delivery_day.day
        new_delivery = DeliverySchedule.find(delivery.delivery_schedule_id).next_delivery_for_date(delivery_day) 
        session[:current_delivery_id] = new_delivery.id
      end
      session[:current_delivery_day] = nil
    end
    if selected = Delivery.current_selected(current_market, session[:current_delivery_id]) 
      selected
    elsif only_delivery = current_market.only_delivery
      session[:current_delivery_id] = only_delivery.id
      only_delivery
    end 
  end

  def selected_organization_location(org=nil)
    if org
      @selected_organization_location ||= (session[:current_location] && org.locations.visible.find_by(id: session[:current_location])) || org.shipping_location
    else
      @selected_organization_location ||= (session[:current_location] && current_organization.locations.visible.find_by(id: session[:current_location])) || current_organization.shipping_location
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

    @current_cart ||= current_user.carts.includes(items: {product: :prices}).find_by(id: session[:cart_id]).try(:decorate)
  end

  def require_cart
    if (!current_user.nil? && !current_organization.nil? && !current_market.nil? && !current_delivery.nil?) || session[:order_id]
      if session[:order_id]
        o=Order.find(session[:order_id])
        @current_cart = Cart.find_or_create_by!(user_id: current_user.id, organization_id: o.organization.id, market_id: o.market.id, delivery_id: o.delivery.id) do |c|
          if !session[:current_location].nil? && o.delivery.requires_location?
            c.location = Location.find(session[:current_location])
          elsif session[:current_location].nil? && o.delivery.requires_location?
            c.location = selected_organization_location(o.organization)
          end
        end.decorate
      else
        if session[:cart_id]
          @current_cart = Cart.find_by(id: session[:cart_id])
          if @current_cart.nil?
            @current_cart = Cart.find_or_create_by!(user_id: current_user.id, organization_id: current_organization.id, market_id: current_market.id, delivery_id: current_delivery.id) do |c|
              if !session[:current_location].nil? && current_delivery.requires_location?
                c.location = Location.find(session[:current_location])
              elsif session[:current_location].nil? && current_delivery.requires_location?
                c.location = selected_organization_location
              end
            end.decorate
          else
            c = @current_cart
            if !session[:current_location].nil? && current_delivery.requires_location?
              c.location = Location.find(session[:current_location])
            elsif session[:current_location].nil? && current_delivery.requires_location?
              c.location = selected_organization_location
            end
            @current_cart = c.decorate
          end
        else
          @current_cart = Cart.find_or_create_by!(user_id: current_user.id, organization_id: current_organization.id, market_id: current_market.id, delivery_id: current_delivery.id) do |c|
            if !session[:current_location].nil? && current_delivery.requires_location?
              c.location = Location.find(session[:current_location])
            elsif session[:current_location].nil? && current_delivery.requires_location?
              c.location = selected_organization_location
            end
          end.decorate
        end
      end
      session[:cart_id] = @current_cart.id
    end
  end

  def require_organization_location
    return unless current_organization && current_organization.locations.visible.none? && session[:order_id].nil?
    redirect_to [:new_admin, current_organization, :location], alert: "You must enter an address for this organization before you can shop"
  end

  def require_manual_delivery_schedule
    return unless current_market.is_consignment_market? && current_market.delivery_schedules.manual.none?
    redirect_to [:new_admin, current_market, :delivery_schedule], alert: "You must enter a manual delivery schedule before you can purchase"
  end

  def require_market_open
    render "shared/market_closed" if current_market.closed? && session[:order_id].nil?
  end

  def require_current_organization
    return unless current_organization.nil? && session[:order_id].nil?
    redirect_to new_sessions_organization_path(redirect_back_to: request.original_url)
  end

  def require_current_supplier
    return unless current_supplier.nil?
    redirect_to new_sessions_supplier_path(redirect_back_to: request.original_url)
  end

  def require_current_delivery
    redir_opts = {}

    if current_delivery.present? || session[:order_id]
      return if session[:order_id] || current_delivery.requires_location? && selected_organization_location.nil?

      if current_delivery.can_accept_orders? || session[:order_id]
        return
      else
        session[:current_delivery_id] = nil
        redir_opts[:alert] = current_delivery.delivery_expired_notice
      end
    end

    redirect_to new_sessions_deliveries_path(redirect_back_to: request.fullpath), redir_opts
  end

  def set_order_id
    @order = !params[:order_id].nil? ? Order.find(params[:order_id]) : nil

    if @order
      session[:order_id] = @order.id
    else
      session[:order_id] = nil
    end
  end

  def reset_order_id
    if !session[:order_id].nil?
      session[:order_id] = nil
      session[:current_delivery_id] = nil
      session[:cart_id] = nil
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:name, :email]
    devise_parameter_sanitizer.for(:account_update).concat [:name]
  end

  def redirect_to_url
    params[:redirect_back_to] || [:products]
  end

  def set_intercom_attributes
    intercom_custom_data.user[:market] = current_market.name if current_market
    intercom_custom_data.user[:org] = current_organization.name if current_organization
  end
end

require Rails.root.join("app/controllers/audited_sweeper")
