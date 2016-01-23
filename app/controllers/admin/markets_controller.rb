class Admin::MarketsController < AdminController
  include StickyFilters

  before_action :require_admin, only: [:new, :create]
  before_action :require_admin_or_market_manager, except: [:new, :create]
  before_action :find_scoped_market, only: [:show, :update, :payment_options, :update_active, :confirm_pending]
  before_action :find_sticky_params, only: :index

  def index
    if params["clear"]
      redirect_to url_for(params.except(:clear))
    else
      if @query_params.empty?
        @query_params = {:q => { :active_eq => true}}
      end
      @search_presenter = MarketSearchPresenter.new(@query_params, current_user)
      @q = search(@search_presenter)

      @markets = @q.result(distinct: true).periscope(request.query_parameters)

      respond_to do |format|
        format.html { @markets = @markets.page(params[:page]).per(params[:per_page]) }
        format.csv { @filename = "markets.csv" }
      end
    end
  end

  def show
  end

  def new
    @market = Market.new(payment_provider: PaymentProvider.for_new_markets.id)
  end

  def create
    results = RegisterStripeMarket.perform(market_params: market_params)

    if results.success?
      redirect_to [:admin, results.market]
    else
      flash.now.alert = "Could not create market"
      @market = results.market
      render :new
    end
  end

  def update
    if @market.update_attributes(market_params)
      redirect_to [:admin, @market]
    else
      flash.now.alert = "Could not update market"
      render :show
    end
  end

  def update_active
    @market.update_attribute(:active, params[:active])
    redirect_to :back, notice: "Updated #{@market.name}"
  end

  def confirm_pending
    @market.update_attribute(:pending, params[:pending])
    redirect_to :back, notice: "Updated #{@market.name}"
    # KXM RYO - Confirm pending should carry on with alla the rest of the pending release:
    #   (1) Notification to Market manager as an account confirmation email (with link back to account setup form),
    #   (2) Activating of Market.
    #
    # Of course, all that is subject to confirmation...
  end

  def payment_options
    @markets = Market.where(id: @market.id)
    render partial: "payment_options"
  end

  protected

  def market_params
    columns = [
      :name,
      :subdomain,
      :tagline,
      :timezone,
      :contact_name,
      :contact_email,
      :contact_phone,
      :facebook,
      :twitter,
      :profile,
      :policies,
      :logo,
      :photo,
      :allow_cross_sell,
      :auto_activate_organizations,
      :closed,
      :store_closed_note,
      :sellers_edit_orders,
      :country,
      :product_label_format,
      :print_multiple_labels_per_item
    ]
    if current_user.can_manage_market?(@market)
      columns.concat([
        :allow_purchase_orders,
        :require_purchase_orders,
        :allow_credit_cards,
        :allow_ach,
        :default_allow_purchase_orders,
        :default_allow_credit_cards,
        :default_allow_ach,
      ])
    end
    if current_user.admin?
      columns.concat([
        :active
      ])
    end
    params.require(:market).permit(columns)
  end

  def market_scope
    Market.managed_by(current_user)
  end

  def find_scoped_market
    @market = market_scope.find(params[:id] || params[:market_id])
  end

  def search(search)
    results = market_scope.search(search.query)

    results
  end
end
