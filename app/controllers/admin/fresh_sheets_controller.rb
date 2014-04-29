class Admin::FreshSheetsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :require_selected_market
  before_action :require_valid_market

  def show
  end

  def update
    sent_fresh_sheet = SendFreshSheet.perform(market: current_market, commit: params[:commit], email: params[:email])
    if sent_fresh_sheet.success?
      redirect_to [:admin, :fresh_sheet], notice: sent_fresh_sheet.notice
    else
      redirect_to [:admin, :fresh_sheet], alert: sent_fresh_sheet.error
    end
  end

  def preview
    email = MarketMailer.fresh_sheet(current_market, current_user.email, true)
    render html: email.body.to_s.html_safe
  end

  protected

  def require_valid_market
    if current_market.delivery_schedules.empty?
      redirect_to [:new_admin, current_market, :delivery_schedule], alert: "You must have a delivery schedule to view the fresh sheet"
    elsif current_market.products.empty?
      render 'no_products'
    end
  end
end
