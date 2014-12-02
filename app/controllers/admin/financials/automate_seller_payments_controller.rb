module Admin::Financials
  class AutomateSellerPaymentsController < AdminController
    before_action :require_admin

    def index
      @as_of_time = Time.current
      @seller_sections = ::Financials::SellerPayments::Finder.find_seller_payment_sections(as_of: @as_of_time)
    end

    def create
      order_ids = params[:order_ids].map do |x| x.to_i end
      unless order_ids.present?
        return redirect_to({action: :index}, {alert: "No orders were selected to pay for"})
      end

      bank_account_id = params[:bank_account_id].to_i
      seller_id = params[:seller_id].to_i
      as_of_time_str = params[:as_of_time]
      as_of_time = Time.zone.parse(as_of_time_str)

      seller_sections = ::Financials::SellerPayments::Finder.find_seller_payment_sections(
        as_of: as_of_time,
        seller_id: seller_id,
        order_id: order_ids
      )
      seller_section = seller_sections.first

      ::Financials::SellerPayments::Processor.pay_and_notify_seller(
        seller_section: seller_section,
        bank_account_id: bank_account_id
      )

      redirect_to({action: :index}, {notice: "Payment recorded"})

    rescue Exception => e
      # Payment failures are serious.  Let's be sure to capture these failures
      # in the log in a way we can monitor and analyze them:
      # NOTE: The PaperTrail add-on for the LO Heroko Production instance has an alert
      # based on the saved search for [AutomateSellerPaymentsController Error] so please
      # be sure to update this text in tandem.
      logger.tagged("AutomateSellerPaymentsController Error") do
        logger.error "While paying/notifying Sellers on Automate plan: #{e.message}: #{e.backtrace.join("\n")}"
      end
      redirect_to({action: :index}, {notice: "Payment failed"})
    end
  end


end
