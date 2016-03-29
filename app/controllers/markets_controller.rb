class MarketsController < ApplicationController
  before_action :hide_admin_navigation
  skip_before_action :require_selected_market, only: [:new]
  skip_before_action :authenticate_user!, except: [:show]
  skip_before_action :ensure_market_affiliation, except: [:show]
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended

  def show
    @market = current_market || Market.find(params[:id])
    if !@market.nil?
      @market = @market.decorate
    end
  end

  ##
  # markets#new AKA Roll Your Own
  ##
  def new
    @plan_data ||= PaymentProvider::Stripe.get_stripe_plans

    requested_plan = params[:plan] || "Start"
    @stripe_plan ||= PaymentProvider::Stripe.get_stripe_plans(requested_plan.upcase)

    plan ||= Plan.find_by stripe_id: requested_plan.upcase

    @market ||= Market.new do |m|
      m.payment_provider = PaymentProvider.for_new_markets.id
      m.pending = true
      m.self_directed_creation = true # This flag says "Yes, I have rolled this myself"
      m.plan_id = plan.id
    end

    render layout: "website-bridge"
  end

  def create
    results = RollYourOwnMarket.perform({
        :market_params => market_params, 
        :billing_params => billing_params, 
        :subscription_params => subscription_params,
        :bank_account_params => bank_account_params,
        :amount => subscription_params[:plan_price], # For 'create_service_payment' interactor
        :flash => flash})

    if results.success?
      flash.notice = "Your request for a new Market will be processed shortly."

      @market = results.market
      @subscription_params = results.subscription_params
      @invoice = results.invoice

      # Email us about their request
      ZendeskMailer.delay.request_market(@market)

      # Email them confirmation of their request
      UserMailer.delay.market_request_confirmation(@market, @invoice)

      redirect_to :action => 'success', :id => @market
    else
      flash.alert = results.context[:error] || "Could not create market"
      @market = results.market
      redirect_to :action => 'new', :id => @market
    end
  end

  def success
    # Give preference to the current_market
    if( current_market )
      @market = current_market
    else
      # Otherwise load it based on the id (if present)
      if( params[:id] )
        @market = Market.find(params[:id])
      end
    end

    render layout: "website-bridge"
  end

  def market_params
    params.require(:market).permit(
      :stripe_tok,
			:contact_name,
			:contact_email,
			:contact_phone,
			:name,
			:subdomain,
      :pending,
      :self_directed_creation,
      :plan,
      :plan_id,
      :coupon
  	)
  end

  def billing_params
    params.require(:billing).permit(
      :address, 
      :city, 
      :state, 
      :country,
      :zip, 
      :phone 
    )
  end

  def subscription_params
    params.require(:details).permit(
      :plan,
      :plan_price,
      :coupon,
    )
  end

  def bank_account_params
    params.require(:market).permit(
      :stripe_tok
    )
  end
end
