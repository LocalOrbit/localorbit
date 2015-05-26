require_relative "../../config/environment"
require_relative "balanced_export"

class SetTransferSchedule
  def initialize(market_id: market_id, dry_run: false)
    @market_id = market_id
    @market = Market.find(@market_id)
    @market_title = "#{@market.name} (#{@market_id})"
    # @export_data = BalancedExport.latest
    @dry_run = dry_run
  end

  def run
    open_log_file

    print_header

    if @market.stripe_account_id
      begin
        stripe_account = Stripe::Account.retrieve(@market.stripe_account_id)
        execute_update log_message: "Stripe Account #{stripe_account.id} - debit_negative_balances: #{stripe_account.debit_negative_balances}, transfer_schedule: #{stripe_account.transfer_schedule.inspect}" do
          stripe_account.transfer_schedule = PaymentProvider::Stripe::TransferSchedule.stringify_keys
          stripe_account.debit_negative_balances = true
          stripe_account.save
        end
      rescue Exception => ex
        log "!! ERROR UPDATING STRIPE ACCOUNT #{@market.stripe_account_id}: #{ex.message}"
      end
    else
      log "!! Market has no stripe_account_id; not updating transfer schedule or debit_negative_balances flag"
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
    log log_message
  end

  def print_header
    log "="*100
    log " #{@market_title}"
    log " Setting transfer schedule and debit_negative_balances flag on Stripe Accounts."
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
    fname = File.dirname(__FILE__) + "/transfer_schedule_logs/market_#{@market.id}.log"
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

market_ids_str = ARGV.shift || raise("Usage: set_transfer_schedule.rb <market_ids>")
market_ids = market_ids_str.gsub(',',' ').split(/\s+/).map(&:strip)

market_ids.each do |market_id|
  updater = SetTransferSchedule.new(
    market_id: market_id,
    # dry_run: false
    dry_run: true
  )
  updater.run
end
