class Admin::NewslettersController < AdminController
  before_action :require_admin_or_market_manager
  before_action :require_selected_market
  before_action :find_newsletter, only: [:edit, :update, :destroy]

  def index
    @newsletters = current_market.newsletters
  end

  def new
    @newsletter = current_market.newsletters.build
  end

  def create
    @newsletter = current_market.newsletters.build(newsletter_params)
    if @newsletter.save
      redirect_to [:admin, :newsletters]
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @newsletter.update(newsletter_params)
      redirect_to [:admin, :newsletters]
    else
      render 'edit'
    end
  end

  def destroy
    @newsletter.destroy
    redirect_to [:admin, :newsletters]
  end

  private

  def find_newsletter
    @newsletter = current_market.newsletters.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:subject, :header, :body, :image)
  end
end
