class Admin::FreshSheetsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :require_selected_market

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

  private

  def require_selected_market
    unless current_market
      render 'shared/select_market'
    end
  end

end
