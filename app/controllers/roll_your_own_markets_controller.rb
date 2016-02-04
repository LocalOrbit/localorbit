class RollYourOwnMarketsController < ApplicationController

	def get_stripe_plans
		# Set secret key
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    requested_plan = params[:plan]
    if(requested_plan == nil)
	    plans = Stripe::Plan.all
    else
	    plans = Stripe::Plan.retrieve(requested_plan)
    end

    @plan_data = plans
		render json: @plan_data
	end

	def get_stripe_coupon
		# Set secret key
    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    coupon = Stripe::Coupon.retrieve(params[:coupon])

		render json: coupon
	end
end