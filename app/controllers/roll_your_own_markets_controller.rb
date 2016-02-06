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

    begin  	
	    if(requested_plan == nil)
	    	if(@_plans)
	    		return @_plans

	    	else
			    @_plans = Stripe::Plan.all
					render json: @_plans
				end

	    else
	    	if(@_plan)
	    		return @_plan

	    	else
			    @_plan = Stripe::Plan.retrieve(requested_plan)
					render json: @_plan
		    end
	    end
    rescue Exception => e
			err = e.json_body[:error]
		  render :status => e.http_status, :text => err[:message]
    end
	end

	def get_stripe_coupon
		if(@_coupon)
			return @_coupon

		else
			# Set secret key
	    Stripe.api_key = Rails.configuration.stripe[:secret_key]

	    begin
		    @_coupon = Stripe::Coupon.retrieve(params[:coupon])
				render json: @_coupon
	    rescue Exception => e
				err = e.json_body[:error]
			  render :status => e.http_status, :text => err[:message]
	    end
	  end
	end
end