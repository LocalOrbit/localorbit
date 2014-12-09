module Admin::Financials
  class AutomateSellerPaymentsController < AdminController
    before_action :require_admin

    def index
      @as_of_time = Time.current
      @seller_sections = ::Financials::SellerPayments::Finder.find_seller_payment_sections(as_of: @as_of_time)
    end

    def create
      #
      # Parameters
      #
      order_ids = params[:order_ids].map do |x| x.to_i end
      unless order_ids.present?
        return redirect_to({action: :index}, {alert: "No orders were selected to pay for"})
      end

      bank_account_id = params[:bank_account_id].to_i

      as_of_time_str = params[:as_of_time]
      as_of_time = Time.zone.parse(as_of_time_str)
      
      seller_id = params[:seller_id].to_i

      #
      # Get payment info
      # 
      seller_sections = ::Financials::SellerPayments::Finder.find_seller_payment_sections(
        as_of: as_of_time,
        seller_id: seller_id,
        order_id: order_ids
      )
      seller_section = seller_sections.first

      flash.notice = "Payment recorded"

      #
      # Execute payment
      #
      payment_config = ::Financials::PaymentMetadata.payment_config_for(:net_to_seller)

      handle_results ::Financials::PaymentProcessor.pay_and_notify(
        payment_config: payment_config,
        inputs: { seller_section: seller_section,
                  bank_account_id: bank_account_id})

      redirect_to action: :index

    rescue Exception => e
      # Payment failures are serious.  Let's be sure to capture these failures
      # in the log in a way we can monitor and analyze them:
      # NOTE: The PaperTrail add-on for the LO Heroko Production instance has an alert
      # based on the saved search for PAYMENT_ERROR so please
      # be sure to update this text in tandem.
      logger.tagged("PAYMENT_ERROR - #{self.class.name}") do
        logger.error "While paying/notifying Sellers on Automate plan: #{e.message}: #{e.backtrace.join("\n")}"
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
