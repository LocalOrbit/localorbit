class Admin::NewslettersController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_market

  def index
    @newsletters = current_market.newsletters
  end

  def new
    @newsletter = @market.newsletters.build
  end

  def create
    @newsletter = @market.newsletters.build(newsletter_params)
    if @newsletter.save
      redirect_to [:admin, @market, :newsletters]
    else
      render 'new'
    end
  end

  def edit
    @newsletter = @market.newsletters.find(params[:id])
  end

  def update
    @newsletter = @market.newsletters.find(params[:id])
    if @newsletter.update(newsletter_params)
      redirect_to [:admin, @market, :newsletters]
    else
      render 'edit'
    end
  end

  private

  def find_market
    @market = current_user.managed_markets.find(params[:market_id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:subject, :header, :body, :image)
  end
end
