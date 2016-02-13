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
    # /roll_your_own_market/get_stripe_plans
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
    binding.pry
    results = RollYourOwnMarket.perform({
        :market_params => market_params, 
        :billing_params => billing_params[:billing], 
        :subscription_params => subscription_params[:post]})

    if results.success?
      @market = results.market
      # KXM Flash alerts aren't working.  Maybe this is due to the redirect or maybe I just suck at programming.  FML.
      # KXM For that matter, flash notices aren't working either, but I suspect it's due to a lack of suitable (read 'any') destination container
      # flash.alert = "Your new market request has been received!  A Local Orbit representative will process your request shortly."
      flash[:notice] = "Your new market request has been received!  A Local Orbit representative will process your request shortly."
      redirect_to :action => 'success', :id => @market, :notice => "Updated #{@market.name}"
    else
      #flash.alert = "Could not create market"
      flash[:err] = "Could not create market"
      @market = results.market
      redirect_to :action => 'new', :id => @market
    end
  end

  def market_params
    params.require(:market).permit(
      :stripe_card_token,
			:contact_name,
			:contact_email,
			:contact_phone,
			:name,
			:subdomain,
      :pending,
      :plan,
      :coupon
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

  def subscription_params
    params.permit(
      post: [
      :plan,
      :price,
      :coupon,
      # KXM I think this isn't working because it doesn't exist in the 'post' bucket.  Look more closely at this whole structure so you know better what to do, OK?  It gets old just sitting here, watching it fail over and over...
      :stripe_card_token
      ]
    )
  end
end
