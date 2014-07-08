class Admin::NewslettersController < AdminController
  before_action :require_admin_or_market_manager
  before_action :require_selected_market
  before_action :find_newsletter, only: [:show, :update, :destroy]

  def index
    @newsletters = current_market.newsletters
  end

  def new
    @newsletter = current_market.newsletters.build
  end

  def create
    @newsletter = current_market.newsletters.build(newsletter_params)
    if @newsletter.save
      send_newsletter
    else
      render "new"
    end
  end

  def show
  end

  def update
    if @newsletter.update(newsletter_params)
      send_newsletter
    else
      render "show"
    end
  end

  def destroy
    @newsletter.destroy
    redirect_to [:admin, :newsletters]
  end

  private

  def send_newsletter
    sent_newsletter = SendNewsletter.perform(newsletter: @newsletter, market: current_market, commit: params[:commit], email: params[:email])
    if sent_newsletter.success?
      redirect_to [:admin, @newsletter], notice: sent_newsletter.notice
    else
      redirect_to [:admin, @newsletter], alert: "There was an error sending this newsletter."
    end
  end

  def find_newsletter
    @newsletter = current_market.newsletters.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(
      :subject, :header, :body,
      :image, :retained_image, :remove_image,
      :buyers, :sellers, :market_managers
    )
  end
end
