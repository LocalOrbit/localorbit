class Admin::MarketsController < AdminController
  def index
    @markets = Market.all
  end

  def show
    @market = Market.find(params[:id])
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
    @market = Market.find(params[:id])
  end

  def update
    @market = Market.find(params[:id])
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
end
