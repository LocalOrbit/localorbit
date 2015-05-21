# ENV['RAILS_ENV'] = 'development'
require_relative "../../config/environment"
# require 'yaml'
# require 'pry'

module PushMarketStripeCustomerIds
  extend self

  def update_markets
    puts "Environment: #{Rails.env}"
    markets = YAML.load_file("tools/stripe-migration/market_stripe_customer_ids.yml")

    markets.each do |m|
      mid = m[:market_id]
      scid = m[:stripe_customer_id]
      if mid and scid
        market = Market.where(id:mid).first
        if market
          log "Update Market #{mid}, set stripe_customer_id #{scid}"
          market.update(stripe_customer_id: scid)
        else
          log "COULD NOT FIND MARKET #{mid} - #{m.inspect}"
        end
      else
        log "NOT UPDATING: #{m.inspect} (missing market_id or stripe_customer_id fields)"
      end
    end
  end

  def log(str)
    $stdout.puts "[#{Time.now.to_s}] - #{self.name} (#{Rails.env}): #{str}"
    $stdout.flush
  end

end

PushMarketStripeCustomerIds.update_markets
