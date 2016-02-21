class MarketsController < ApplicationController
  before_action :hide_admin_navigation
  skip_before_action :require_selected_market, only: [:new]
  skip_before_action :authenticate_user!, except: [:show]
  skip_before_action :ensure_market_affiliation, except: [:show]
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended

  def show
    @market = current_market || Market.find(params[:id])
    @market.try(:decorate)
  end

  def new
    # /roll_your_own_market/get_stripe_plans
    # KXM The Stripe calls here should probably be rolled into the RollYourOwnMarkets controller (the name of which should change), but how to make an API call to the local endpoint?  Google suggests the HTTParty gem, but I'm not crazy about rolling in that kind of heavy weight solution just to facilitate a minor code refactoring
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    @plan_data ||= Stripe::Plan.all.data

    requested_plan = params[:plan] || "Start"
    @stripe_plan ||= Stripe::Plan.retrieve(requested_plan.upcase)

    plan ||= Plan.find_by stripe_id: requested_plan.upcase

    @market ||= Market.new do |m|
      m.payment_provider = PaymentProvider.for_new_markets.id
      m.pending = true
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
      @market = results.market
      flash.notice = "Your request for a new Market will be processed shortly."
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
