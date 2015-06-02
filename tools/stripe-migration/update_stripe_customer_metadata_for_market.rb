require_relative "../../config/environment"
require 'pry'

class UpdateStripeCustomerMetadataForMarket
  def initialize(market_id: market_id, dry_run: false)
    @market_id = market_id
    @market = Market.find(@market_id)
    @market_title = "#{@market.name} (#{@market_id})"
    @dry_run = dry_run
  end

  def run
    open_log_file

    print_header

    begin

      market_customer = @market.stripe_customer
      if market_customer
        info = stripe_customer_info(@market)
        execute_update log_message: "Updating Market's Stripe Customer with #{info.inspect}" do
          update_customer market_customer, info
        end
      else
        log "No Stripe Customer linked to this Market."
      end

      orgs = @market.organizations.visible
      orgs.each do |org|
        org_title = "Organization #{org.name} (#{org.id})"

        organization_title = "#{org.name} (#{org.id})"
        org_customer = org.stripe_customer
        if org_customer

          info = stripe_customer_info(org)
          execute_update log_message: "Updating Organization #{organization_title}'s Stripe Customer #{org_customer.id} with #{info.inspect}" do
            update_customer org_customer, info
          end
        else
          log "No Stripe Customer linked to #{organization_title}."
        end
      end

          
    rescue Exception => ex
      log "!! ERROR UPDATING STRIPE CUSTOMER METADATA - #{@market.stripe_account_id}: #{ex.message}"
    end

  ensure
    close_log_file
  end

  def update_customer(stripe_customer, info)
    stripe_customer.description = info[:description]
    stripe_customer.metadata["lo.entity_id"] = info[:metadata]["lo.entity_id"]
    stripe_customer.metadata["lo.entity_type"] = info[:metadata]["lo.entity_type"]
    stripe_customer.save
  rescue Exception => e
    log "!! ERROR UPDATING STRIPE CUSTOMER METADATA #{stripe_customer.id} with #{info.inspect}"
  end

  def stripe_customer_info(entity)
    {
      description: entity.name,
      metadata: {
        "lo.entity_id" => entity.id,
        "lo.entity_type" => entity.class.name.underscore
      }
    }
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
    log " Updating stripe customer metadata for Market and all Organizations."
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
    fname = File.dirname(__FILE__) + "/update_customer_metadata_logs/market_#{@market.id}.log"
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

market_ids_str = ARGV.shift || raise("Usage: update_stripe_customer_metadata_for_market.rb <market_ids>")
market_ids = market_ids_str.gsub(',',' ').split(/\s+/).map(&:strip)

market_ids.each do |market_id|
  updater = UpdateStripeCustomerMetadataForMarket.new(
    market_id: market_id,
    dry_run: false
    # dry_run: true
  )
  updater.run
end
