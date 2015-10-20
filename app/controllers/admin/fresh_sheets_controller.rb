class Admin::FreshSheetsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :require_selected_market
  before_action :require_valid_market
  before_action :load_fresh_sheet, only: [:create, :preview, :show]

  def show
  end

  def create
    note = params[:note]
    update_fresh_sheet_note(note)

    if params[:commit] == "Add Note"
      redirect_to([:admin, :fresh_sheet], notice: "Note saved.") && return
    end

    sent_fresh_sheet = SendFreshSheet.perform(market: current_market, commit: params[:commit], email: params[:email], note: note, port: request.port)
    if sent_fresh_sheet.success?
      clear_fresh_sheet_note if params[:commit] == "Send to Everyone Now"
      redirect_to [:admin, :fresh_sheet], notice: sent_fresh_sheet.notice
    else
      redirect_to [:admin, :fresh_sheet], alert: sent_fresh_sheet.error
    end
  end

  def preview
    email = MarketMailer.fresh_sheet(
      market: current_market, 
      to: current_user.email, 
      note: @note.html_safe,
      preview: true, 
      unsubscribe_token: "XYZ987XYZ987XYZ987",
      port: request.port
    )
    render html: email.body.to_s.html_safe
  end

  protected

  def load_fresh_sheet
    @fresh_sheet = FreshSheet.find_or_create_by(market: current_market, user: current_user)
    @note = @fresh_sheet.note
  end

  def update_fresh_sheet_note(note)
    @note = note
    @fresh_sheet.update(note: @note)
  end

  def clear_fresh_sheet_note
    update_fresh_sheet_note(nil)
  end

  def require_valid_market
    if current_market.delivery_schedules.empty?
      redirect_to [:new_admin, current_market, :delivery_schedule], alert: "You must have a delivery schedule to view the fresh sheet"
    elsif current_market.products.empty?
      render "no_products"
    end
  end
end
