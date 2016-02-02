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
    @market = Market.new(payment_provider: PaymentProvider.for_new_markets.id)
    @market.pending = true;

    # KXM The hard-coded value is brittle, as is the expectation that the supplied parameter will match a plan. Perhaps a default flag in the plan table and a corresponding class method that recalls the associated record? 
    plan = Plan.find_by name: params[:plan] || "Start Up"
    @market.plan_id = plan.id
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
    # The question is "Do I really need the market here"
    render layout: "website-bridge"
  end

  def create
    if(false)
      render :success, layout: "website-bridge"
    else
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
