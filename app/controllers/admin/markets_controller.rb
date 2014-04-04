class Admin::MarketsController < AdminController
  before_action :require_admin, only: [:new, :create]
  before_action :require_admin_or_market_manager, except: [:new, :create]

  def index
    @markets = market_scope
  end

  def show
    @market = market_scope.find(params[:id])
  end

  def new
    @market = Market.new
  end

  def create
    results = RegisterMarket.perform(market_params: market_params)

    if results.success?
      redirect_to [:admin, results.market]
    else
      @market = results.market
      render :new
    end
  end

  def edit
    @market = market_scope.find(params[:id])
  end

  def update
    @market = market_scope.find(params[:id])
    if @market.update_attributes(market_params)
      redirect_to [:edit, :admin, @market]
    else
      render :edit
    end
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
      :background,
    )
  end

  def market_scope
    current_user.admin? ? Market.all : current_user.managed_markets
  end
end
