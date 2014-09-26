class SubscriptionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_market_affiliation
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended

  before_action do
    @show_nav_tagline = true # forces market tagline to show even if user not logged in.
  end

  def unsubscribe
    get_token_and_subscription_type
  rescue Exception => e
    redirect_to confirm_unsubscribe_subscriptions_path(skip:true)
  end

  def confirm_unsubscribe
    if params[:skip]
      @token = nil
      @subscription_name = "Emails"
    else
      get_token_and_subscription_type
      Subscription.unsubscribe_by_token(@token)
    end
  end

  private
  def get_token_and_subscription_type
    @token = params.require(:token)
    subscription_type = Subscription.find_by(token: @token).subscription_type
    @subscription_name = subscription_type.name
  end
end
