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
    @market = Market.create(market_params)
    if @market.errors.any?
      render :new
    else
      redirect_to [:admin, @market]
    end
  end

  def edit
    @market = market_scope.find(params[:id])
  end

  def update
    @market = market_scope.find(params[:id])
    if @market.update_attributes(market_params)
      redirect_to [:admin, @market]
    else
      render :edit
    end
  end

  protected

  def market_params
    params.require(:market).permit(
      :name,
      :subdomain,
      :timezone,
      :active,
      :contact_name,
      :contact_email,
      :contact_phone,
      :facebook,
      :twitter,
      :profile,
      :policies
    )
  end

  def market_scope
    current_user.admin? ? Market.all : current_user.managed_markets
  end
end
