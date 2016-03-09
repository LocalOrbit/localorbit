class Admin::MarketStripeController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_market

  def show
    @market = Market.find(params[:market_id])

    if !@market.stripe_account_id.nil?
      @account_balance = PaymentProvider::Stripe.get_stripe_balance(@market.stripe_account_id)
      @account_payments = PaymentProvider::Stripe.get_stripe_balance_transactions(@market.stripe_account_id)
      @account_transfers = PaymentProvider::Stripe.get_stripe_transfers(@market.stripe_account_id)
    end
  end
end