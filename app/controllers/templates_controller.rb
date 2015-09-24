class TemplatesController < ApplicationController
  before_action :require_selected_market
  before_action :check_access

  def index
  end

  def new
  end

  private

  def check_access
    if !FeatureAccess.order_templates?(market: current_market)
      render(:file => File.join(Rails.root, 'public/404.html'), :status => 404, :layout => false)
    end
  end
end
