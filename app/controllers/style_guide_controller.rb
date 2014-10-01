class StyleGuideController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_market_affiliation
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended
  
  def index
    raise ActionController::RoutingError.new('Not Found') if Figaro.env.deploy_env == 'production'
  end
end
