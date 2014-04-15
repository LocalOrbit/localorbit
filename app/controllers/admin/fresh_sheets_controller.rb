class Admin::FreshSheetsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :require_selected_market
  before_action :require_valid_market

  def show
  end

  def update
    if params.require(:commit) == "Send Test"
      email = params.require(:email)
      MarketMailer.fresh_sheet(current_market, email).deliver
      redirect_to [:admin, :fresh_sheet], notice: "Successfully sent a test to #{email}"
    elsif params.require(:commit) == "Send to Everyone Now"
      MarketMailer.fresh_sheet(current_market).deliver
      redirect_to [:admin, :fresh_sheet], notice: "Successfully sent the Fresh Sheet"
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
