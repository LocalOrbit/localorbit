class Admin::MarketsController < AdminController
  before_action :require_admin, only: [:new, :create]
  before_action :require_admin_or_market_manager, except: [:new, :create]
  before_action :find_scoped_market, only: [:show, :update, :defaults]

  def index
    @markets = market_scope
  end

  def show
  end

  def new
    @market = Market.new
  end

  def create
    results = RegisterMarket.perform(market_params: market_params)

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

  def defaults
    render partial: 'defaults'
  end

  protected

  def market_params
    params.require(:market).permit(
      :name,
      :subdomain,
      :tagline,
      :timezone,
      :active,
      :contact_name,
      :contact_email,
      :contact_phone,
      :facebook,
      :twitter,
      :profile,
      :policies,
      :logo,
      :photo,
      :allow_purchase_orders,
      :allow_credit_cards,
      :default_allow_purchase_orders,
      :default_allow_credit_cards
    )

  end

  def market_scope
    current_user.admin? ? Market.all : current_user.managed_markets
  end

  def find_scoped_market
    @market = market_scope.find(params[:id ] || params[:market_id])
  end
end
