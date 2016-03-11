class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def stripe_connect
    # Delete the code inside of this method and write your own.
    # The code below is to show you where to access the data.

    @market = Market.find_by_subdomain(params[:state])

    if @market.legacy_stripe_account_id.nil?
      @market.legacy_stripe_account_id = @market.stripe_account_id
    end

    @market.stripe_account_id = request.env["omniauth.auth"]["extra"]["extra_info"]["id"]
    @market.save

    server_name = request.server_name.sub 'app.', "#{params[:state]}."

    redirect_to "#{request.protocol}#{server_name}:#{request.port}/admin/markets/#{@market.id}/stripe", notice: "Account Connected to Stripe"
  end
end