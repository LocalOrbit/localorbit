
require_relative "../../config/environment"
require 'pry'

        # cust_keys = %w{id description created livemode sources}.map(&:to_sym)
        #   keys = %w{id last4 brand funding exp_year exp_month fingerprint country name}.map(&:to_sym)
# DownloadCustomerMetadata.go file: "tools/stripe-migration/downloaded_customers.yml"
data = YAML.load_file("tools/stripe-migration/downloaded_customers.yml")
 
data.each do |c|
  stripe_customer_id = c[:id]
  balanced_customer_id = c[:metadata][:"balanced.customer_id"]
  snippet = "balanced_customer_uri LIKE '%/#{balanced_customer_id}'"
  binding.pry
  if organization = Organization.where(snippet).first
    x = { match_type: :organization, organization_id: organization.id, balanced_customer_id: balanced_customer_id, stripe_customer_id: stripe_customer_id }
    p x
  elsif market = Market.where(snippet).first
    x = { match_type: :market, market_id: market.id, balanced_customer_id: balanced_customer_id, stripe_customer_id: stripe_customer_id }
    p x
  else
    x = { match_type: :none, balanced_customer_id: balanced_customer_id, stripe_customer_id: stripe_customer_id }
    p x
  end
end


