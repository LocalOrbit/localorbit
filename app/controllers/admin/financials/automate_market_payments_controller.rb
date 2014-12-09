module Admin::Financials
  class AutomateMarketPaymentsController < AdminController
    before_action :require_admin

    def index
      @as_of_time = Time.current
      @market_sections = ::Financials::MarketPayments::Finder.find_market_payment_sections(as_of: @as_of_time)
    end

    def create
      #
      # Parameters:
      #
      order_ids = params[:order_ids].map do |x| x.to_i end
      unless order_ids.present?
        return redirect_to({action: :index}, {alert: "No orders were selected to pay for"})
      end

      bank_account_id = params[:bank_account_id].to_i

      as_of_time_str = params[:as_of_time]
      as_of_time = Time.zone.parse(as_of_time_str)

      market_id = params[:market_id].to_i

      market_sections = ::Financials::MarketPayments::Finder.find_market_payment_sections(
        as_of: as_of_time,
        market_id: market_id,
        order_id: order_ids
      )
      market_section = market_sections.first

      flash.notice = "Payment recorded"

      #
      # Market fees:
      #
      market_payment_config = ::Financials::PaymentMetadata.payment_config_for(:market_fees_to_market)

      handle_results ::Financials::PaymentProcessor.pay_and_notify(
        payment_config: market_payment_config,
        inputs: { market_section: market_section,
                  bank_account_id: bank_account_id})

      #
      # Delivery fees:
      #
      delivery_payment_config = ::Financials::PaymentMetadata.payment_config_for(:delivery_fees_to_market)
      
      handle_results ::Financials::PaymentProcessor.pay_and_notify(
        payment_config: delivery_payment_config,
        inputs: { market_section: market_section,
                  bank_account_id: bank_account_id})

      redirect_to action: :index

    rescue Exception => e
      # Payment failures are serious.  Let's be sure to capture these failures
      # in the log in a way we can monitor and analyze them:
      # NOTE: The PaperTrail add-on for the LO Heroko Production instance has an alert
      # based on the saved search for PAYMENT_ERROR so please
      # be sure to update this text in tandem.
      logger.tagged("PAYMENT_ERROR - #{self.class.name}") do
        logger.error "While paying/notifying Market on Automate plan: #{e.message}: #{e.backtrace.join("\n")}"
      end
      flash_payment_failed
      redirect_to action: :index
    end

    private

    def flash_payment_failed
      flash.notice = nil
      flash.alert = "Payment failed"
    end

    def handle_results(results)
      if results[:status] != :ok
        logger.tagged("PAYMENT_ERROR - #{self.class.name}") do
          logger.error("Result status: #{results[:status].inspect}, #{results[:message]}")
          logger.error("Payment: #{results[:payment].inspect}")
        end
        flash_payment_failed
      end
    end
  end


end
