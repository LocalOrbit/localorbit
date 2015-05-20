require_relative "../../config/environment"
require_relative "balanced_export"

class UpdateStripeIdsOnMarket
  def initialize(market_id: market_id, dry_run: false)
    @market_id = market_id
    @market = Market.find(@market_id)
    @market_title = "#{@market.name} (#{@market_id})"
    @export_data = BalancedExport.latest
    @dry_run = dry_run
  end

  def run
    open_log_file

    print_header

    export_data = BalancedExport.latest

    if @market.balanced_customer_uri
      update_market_stripe_customer_id 
      update_market_stripe_account_id 
    else
      log "!! Market has no balanced_customer_uri; not updating its stripe_customer_id or stripe_account_id"
    end

    update_organization_stripe_customer_ids_in_market

    update_bank_account_stripe_ids_in_market
  ensure
    close_log_file
  end

  def update_market_stripe_customer_id
    if scid = @export_data.stripe_customer_id_for_balanced_customer_uri(@market.balanced_customer_uri)
      execute_update log_message: "Connecting market customer - Updated Market stripe_customer_id: #{scid}" do
        @market.update(stripe_customer_id: scid)
      end
    else
      log "Connecting market customer - MISS - No stripe_customer_id found for market balanced_customer_uri #{@market.balanced_customer_uri}"
    end
  end


  def update_market_stripe_account_id
    if said = @export_data.stripe_account_id_for_balanced_customer_uri(@market.balanced_customer_uri)
      execute_update log_message: "Connecting market account - Updated Market stripe_account_id: #{said}" do
        @market.update(stripe_account_id: said)
      end
    else
      log "Connecting market account - MISS - No stripe_account_id found for market balanced_customer_uri #{@market.balanced_customer_uri}"
    end
  end

  def update_organization_stripe_customer_ids_in_market
    orgs = get_market_organizations
    orgs.each do |org|
      update_organization_stripe_customer_id(org)
    end
  end

  def update_organization_stripe_customer_id(org)
    org_title = "Organization #{org.name} (#{org.id})"
    if scid = @export_data.stripe_customer_id_for_balanced_customer_uri(org.balanced_customer_uri)
      execute_update log_message: "Connecting org customers - Updated #{org_title} stripe_customer_id: #{scid}" do
        org.update(stripe_customer_id: scid)
      end
    else
      log "Connecting org customers - MISS - No stripe_customer_id found for #{org_title} balanced_customer_uri #{org.balanced_customer_uri}"
    end
  end

  def update_bank_account_stripe_ids_in_market
    # Bank Accounts for Markets:
    market_bank_accounts = @market.bank_accounts.where('balanced_uri IS NOT NULL')
    market_bank_accounts.each do |ba|
      update_bank_account_stripe_id ba, prefix: "Connecting market BankAccounts"
    end

    # Bank Accounts for Orgs:
    orgs = get_market_organizations
    orgs.each do |org|
      org_title = "Organization #{org.name} (#{org.id})"
      org_bank_accounts = org.bank_accounts.where('balanced_uri IS NOT NULL')
      org_bank_accounts.each do |ba|
        update_bank_account_stripe_id ba, prefix: "Connecting org BankAccounts - #{org_title}"
      end
    end
  end

  def execute_update(log_message:,&block)
    if @dry_run
      # log "(DRY RUN: not executing the update)"
    else
      block.call
    end
    log log_message
  end

  def update_bank_account_stripe_id(ba,prefix:"?")
    bank_account_title = "#{ba.bank_name} #{ba.last_four} (#{ba.id})"
    if sid = @export_data.stripe_id_for_bank_account_balanced_uri(ba.balanced_uri)
      execute_update log_message: "#{prefix} - Updated #{bank_account_title} stripe_id: #{sid}" do
        ba.update(stripe_id: sid)
      end
    else
      log "#{prefix} - MISS - No stripe_id found for #{bank_account_title} balanced_customer_uri #{ba.balanced_uri}"
    end
  end

  def get_market_organizations
    orgs_with_bcu = @market.organizations.visible.where('balanced_customer_uri IS NOT NULL')
    orgs_with_bcu
  end

  def print_header
    log "="*100
    log " #{@market_title}"
    log " Updating stripe IDs for market, orgs and bank accounts."
    log ""
    log " Rails.env: #{Rails.env}"
    log " Stripe keys:"
    # %w{STRIPE_SECRET_KEY STRIPE_PUBLISHABLE_KEY}.each do |k|
    %w{STRIPE_PUBLISHABLE_KEY}.each do |k|
      v = Figaro.env.send(k.downcase)
      v2 = ENV[k]
      log "  --> #{k}: #{v} (#{v2})"
    log "="*100
    end
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
    fname = File.dirname(__FILE__) + "/update_logs/market_#{@market.id}.log"
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

market_ids_str = ARGV.shift || raise("Usage: update_stripe_ids_on_market.rb <market_ids>")
market_ids = market_ids_str.gsub(',',' ').split(/\s+/).map(&:strip)

market_ids.each do |market_id|
  updater = UpdateStripeIdsOnMarket.new(
    market_id: market_id,
    dry_run: true
  )
  updater.run
end
