# based on examples from Zendesk:
# https://github.com/zendesk/zendesk_jwt_sso_examples/blob/master/ruby_on_rails_jwt.rb
class ZendeskSSOController < ApplicationController
  # Configuration
  ZENDESK_SHARED_SECRET = ENV["ZENDESK_SHARED_SECRET"]
  ZENDESK_SUBDOMAIN     = ENV["ZENDESK_SUBDOMAIN"]

  skip_before_action :ensure_market_affiliation

  def show
    sign_into_zendesk(current_user)
  end

  private

  def sign_into_zendesk(user)
    # This is the meat of the business, set up the parameters you wish
    # to forward to Zendesk. All parameters are documented in this page.
    iat = Time.now.to_i
    jti = "#{iat}/#{SecureRandom.hex(18)}"

    payload = JWT.encode({
      iat: iat, # Seconds since epoch, determine when this token is stale
      jti: jti, # Unique token id, helps prevent replay attacks
      name: user.name,
      email: user.email,
      external_id: user.id.to_s,
    }, ZENDESK_SHARED_SECRET.to_s)

    redirect_to zendesk_sso_url(payload)
  end

  def zendesk_sso_url(payload)
    url = "https://#{ZENDESK_SUBDOMAIN}.zendesk.com/access/jwt?jwt=#{payload}"
    url += "&return_to=#{URI.escape(params["return_to"])}" if params["return_to"].present?
    url
  end
end