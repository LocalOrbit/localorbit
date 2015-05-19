# ENV['RAILS_ENV'] = 'development'
require_relative "../../config/environment"
# require 'yaml'
# require 'pry'

module PushMarketStripeMarketIds
  extend self

  def update_markets
    puts "Environment: #{Rails.env}"
    markets = YAML.load_file("tools/stripe-migration/market_stripe_account_ids.yml")

    markets.each do |m|
      mid = m[:market_id]
      said = m[:stripe_account_id]
      if mid and said
        market = Market.where(id:mid).first
        if market
          log "Update Market #{mid}, set stripe_account_id #{said}"
          market.update(stripe_account_id: said)
        else
          log "COULD NOT FIND MARKET #{mid} - #{m.inspect}"
        end
      else
        log "NOT UPDATING: #{m.inspect} (missing market_id or stripe_account_id fields)"
      end
    end
  end

  def log(str)
    $stdout.puts "[#{Time.now.to_s}] - #{self.name} (#{Rails.env}): #{str}"
    $stdout.flush
  end

end

PushMarketStripeMarketIds.update_markets
