class TemplatesController < ApplicationController
  before_action :require_selected_market
  before_action :check_access

  def index
    if current_user.market_manager?
      templates = OrderTemplate.where("market_id = ? AND buyer_id IS NULL", current_market.id)
    else
      templates = OrderTemplate.where("market_id = ? AND buyer_id = ?", current_market.id, current_organization.id)
    end
    templates
  end

  def new
  end

  private

  def check_access
    if !Pundit.policy(current_user, :template)
      render(:file => File.join(Rails.root, 'public/404.html'), :status => 404, :layout => false)
    end
  end
end
