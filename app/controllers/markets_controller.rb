class MarketsController < ApplicationController
  before_action :hide_admin_navigation
  skip_before_action :require_selected_market, only: [:new]
  skip_before_action :authenticate_user!
  skip_before_action :ensure_market_affiliation
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended
  def show
    @market = current_market.decorate
  end

  def new
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    plans = Stripe::Plan.all
    @plan_data = plans.data

    requested_plan = params[:plan] || "Start"
    @stripe_plan = Stripe::Plan.retrieve(requested_plan.upcase)

    plan = Plan.find_by stripe_id: requested_plan.upcase

    @market = Market.new do |m|
      m.payment_provider = PaymentProvider.for_new_markets.id
      m.pending = true
      m.plan_id = plan.id
    end

    render layout: "website-bridge"
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

  def create
    results = RollYourOwnMarket.perform({:market_params => market_params, :billing_params => billing_params[:billing]})

    if results.success?
      @market = results.market
      redirect_to :action => 'success', :id => @market
    else
      flash.now.alert = "Could not create market"
      @market = results.market
      render :new
    end
  end

  def market_params
    params.require(:market).permit(
			:contact_name,
			:contact_email,
			:contact_phone,
			:name,
			:subdomain,
      :pending,
      :plan_id
  	)
  end

  def billing_params
    params.permit(
      billing: [
        :address, 
        :city, 
        :state, 
        :zip, 
        :phone 
      ]
    )
  end
end
