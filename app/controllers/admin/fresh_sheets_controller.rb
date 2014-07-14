class Admin::FreshSheetsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :require_selected_market
  before_action :require_valid_market
  before_action :load_saved_note, only: [:preview, :show]

  def show
  end

  def create
    session[:fresh_sheet_note] = params[:note]

    if params[:commit] == "Save Note"
      redirect_to [:admin, :fresh_sheet], notice: "Note saved." and return
    end

    sent_fresh_sheet = SendFreshSheet.perform(market: current_market, commit: params[:commit], email: params[:email], note: session[:fresh_sheet_note])
    if sent_fresh_sheet.success?
      session[:fresh_sheet_note] = nil if params[:commit] == "Send to Everyone Now"
      redirect_to [:admin, :fresh_sheet], notice: sent_fresh_sheet.notice
    else
      redirect_to [:admin, :fresh_sheet], alert: sent_fresh_sheet.error
    end
  end

  def preview
    email = MarketMailer.fresh_sheet(current_market, current_user.email, @note, true)
    render html: email.body.to_s.html_safe
  end

  protected

  def load_saved_note
    @note = session[:fresh_sheet_note]
  end

  def require_valid_market
    if current_market.delivery_schedules.empty?
      redirect_to [:new_admin, current_market, :delivery_schedule], alert: "You must have a delivery schedule to view the fresh sheet"
    elsif current_market.products.empty?
      render "no_products"
    end
  end
end
