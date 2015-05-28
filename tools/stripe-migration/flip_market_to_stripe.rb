require_relative "../../config/environment"
require 'pry'

class FlipMarketToStripe
  def initialize(market_id: market_id, dry_run: false, only_flip_markets_with_stripe_accounts: true)
    @market_id = market_id
    @market = Market.find(@market_id)
    @market_title = "#{@market.name} (#{@market_id})"
    @dry_run = dry_run
    @only_flip_markets_with_stripe_accounts = only_flip_markets_with_stripe_accounts
  end

  def run
    open_log_file

    print_header

    payment_provider = PaymentProvider::Stripe
    payment_provider_id = payment_provider.id


    unless @only_flip_markets_with_stripe_accounts and !@market.stripe_account_id
      begin
        execute_update log_message: "Flipped Market to use Stripe payment provider." do
          @market.update(
            payment_provider: payment_provider_id,
            # allow_ach: false, # XXX Not yet.  Let's leave this as knowledge, overridden by the fact that the payment provider doesn't support ACH.
            # default_allow_ach: false # XXX Not yet.  Let's leave this as knowledge, overridden by the fact that the payment provider doesn't support ACH.
          )

          # @market.organizations.update_all(allow_ach: false) # XXX Not yet.  Let's leave this as knowledge, overridden by the fact that the payment provider doesn't support ACH.
        end
          
      rescue Exception => ex
        log "!! ERROR FLIPPING MARKET TO STRIPE ACCOUNT - #{@market.stripe_account_id}: #{ex.message}"
      end
    else
      log "!! only_flip_markets_with_stripe_accounts is #{@only_flip_markets_with_stripe_accounts}... and since Market has no stripe_account_id; NOT UPDATING PAYMENT PROVIDER"
    end

  ensure
    close_log_file
  end

  def execute_update(log_message:,&block)
    if @dry_run
      # log "(DRY RUN: not executing the update)"
    else
      block.call
    end
    if log_message.respond_to?(:call)
      log_message = log_message.call()
    end
    log log_message
  end

  def print_header
    log "="*100
    log " #{@market_title}"
    log " Flipping market to use Stripe."
    log ""
    log " Rails.env: #{Rails.env}"
    log " Stripe key: #{ENV['STRIPE_PUBLISHABLE_KEY']}" 
    log "="*100
    if @dry_run
      log ""
      log "<<< DRY RUN - NO UPDATES WILL ACTUALLY BE EXECUTED >>>"
      log ""
    end
  end

  def log(str)
    msg = "[#{Time.now}] - #{self.class.name} - #{@market_title} - #{str}"
    $stdout.puts msg
    $stdout.flush
    @log_file.puts msg
    @log_file.flush
  end

  def open_log_file
    fname = File.dirname(__FILE__) + "/flip_market_logs/market_#{@market.id}.log"
    @log_file = File.open(fname,"w")
  end

  def close_log_file
    begin
      @log_file.close if @log_file
    rescue Exception => e
      # nothing
    end
    @log_file = nil
  end
end

market_ids_str = ARGV.shift || raise("Usage: flip_market_to_stripe.rb <market_ids>")
market_ids = market_ids_str.gsub(',',' ').split(/\s+/).map(&:strip)

market_ids.each do |market_id|
  updater = FlipMarketToStripe.new(
    market_id: market_id,
    only_flip_markets_with_stripe_accounts: false,
    dry_run: false
    # dry_run: true
  )
  updater.run
end
