class RollYourOwnMarketsController < ApplicationController
  skip_before_action :require_selected_market
  skip_before_action :authenticate_user!
  skip_before_action :ensure_market_affiliation
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended

	# Cached data objects
	@_plans  = {}
	@_plan   = {}
	@_coupon = {}

	def get_stripe_plans
		# Set secret key
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    requested_plan = params[:plan]

  	# If no plan is sent...
    if(requested_plan == nil)
    	# ...then return the cached plan list...
    	@_plans ||= 
	    begin
    		# ...or get them from Stripe
		    @_plans = Stripe::Plan.all
				render json: @_plans

	    rescue Exception => e
	    	# Pass on any errors
				err = e.json_body[:error]
			  render :status => e.http_status, :text => err[:message]
			end

  	# If a plan is sent...
    else
  		# ...then return the cached plan
    	@_plan ||=
    	begin
    		# ...or get it from Stripe
		    @_plan = Stripe::Plan.retrieve(requested_plan)
				render json: @_plan

	    rescue Exception => e
	    	# Pass on any errors
				err = e.json_body[:error]
			  render :status => e.http_status, :text => err[:message]
	    end
    end
	  #render :status => 500, :text => "There was a problem retrieving results"
	end

	def get_stripe_coupon
		@_coupon ||= 
		begin
			# Set secret key
	    Stripe.api_key = Rails.configuration.stripe[:secret_key]

	    @_coupon = Stripe::Coupon.retrieve(params[:coupon])
			render json: @_coupon
			
		rescue Exception => e
			err = e.json_body[:error]
		  render :status => e.http_status, :text => err[:message]
    end
	end
end