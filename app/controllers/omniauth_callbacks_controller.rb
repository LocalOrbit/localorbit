class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def stripe_connect
    # Delete the code inside of this method and write your own.
    # The code below is to show you where to access the data.

    @market = Market.find_by_subdomain(params[:state])

    @market.stripe_account_id = request.env["omniauth.auth"]["extra"]["extra_info"]["id"]
    @market.save!

    redirect_to "/admin/market/#{@market.id}/stripe"

    #raise request.env["omniauth.auth"].to_yaml
  end
end