require "spec_helper"

describe Admin::Financials::AutomateSellerPaymentsController do
  include_context "the mini market"

  let(:seller_sections) { [double("Seller Section 1"), double("Seller Section 2")] }
  let(:payment) { double "Payment", status: "pending" }

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in aaron
  end

  def begin_log_capture
    require 'stringio'
    @log_io = StringIO.new
    l = ActiveSupport::Logger.new(@log_io)
    @logger2 = ActiveSupport::TaggedLogging.new(l)
    @saved_controller_logger = controller.logger
    controller.logger = @logger2
  end

  def end_log_capture
    controller.logger = @saved_controller_logger
    data = @log_io.string
    return data
  end

  describe "#index" do
    it "provides all potentially payable sellers by assigning SellerSections" do
      search_as_of = nil
      expect(::Financials::SellerPayments::Finder).to receive(:find_seller_payment_sections) do |opts|
        search_as_of = opts[:as_of]
        seller_sections
      end
      get :index
      expect(assigns[:as_of_time]).to be_within(5.seconds).of(Time.current)
      expect(search_as_of).to eq(assigns[:as_of_time])
      expect(assigns[:seller_sections]).to eq seller_sections
    end
  end

  describe "#create" do
    let (:order_ids) { %w(101 102 103) }
    let (:bank_account_id) { "999" }
    let (:seller_id) { "300" }
    let (:as_of_time) { Time.zone.parse("Nov 16 2014 12:30pm").to_s }

    let(:net_to_seller) { ::Financials::PaymentMetadata::payment_config_for(:net_to_seller) }

    let(:results) { 
      { status: :ok, payment: double("Seller payment") }
    }
    let(:failing_results) { 
      { status: :oopsie, message: "Things went awry", payment: double("Failed Seller Payment") }
    }

    def expect_find_seller_sections
      expect(::Financials::SellerPayments::Finder).to receive(:find_seller_payment_sections).
        with(as_of: Time.zone.parse(as_of_time),
             seller_id: 300,
             order_id: [101,102,103]).
        and_return(seller_sections)
    end

    def expect_pay_and_notify
      expect(::Financials::PaymentProcessor).to receive(:pay_and_notify).
        with(payment_config: net_to_seller,
             inputs: { seller_section: seller_sections.first,
             bank_account_id: bank_account_id.to_i})
    end

    def post_create
      post :create, 
        seller_id: seller_id, 
        order_ids: order_ids, 
        bank_account_id: bank_account_id,
        as_of_time: as_of_time
    end

    it "re-loads the SellerSections filtered by selected seller and orders then executes the payment" do
      expect_find_seller_sections

      expect_pay_and_notify.
        and_return(results)

      post_create

      expect(response).to redirect_to(admin_financials_automate_seller_payments_path)
      expect(flash.notice).to eq "Payment recorded"
    end

    context "when results comes back failed" do
      it "complains via an alert" do
        expect_find_seller_sections

        expect_pay_and_notify.
          and_return(failing_results)

        begin_log_capture

        post_create

        log_data = end_log_capture

        expect(response).to redirect_to(admin_financials_automate_seller_payments_path)
        expect(flash.alert).to eq "Payment failed"

        expect(log_data).to match(/PAYMENT_ERROR - #{controller.class.name}/)
        expect(log_data).to match(/Result status: :oopsie/)
        expect(log_data).to match(/Things went awry/)
        expect(log_data).to match(/#{Regexp.escape(failing_results[:payment].inspect)}/)
      end
    end

    context "when exception occurs" do
      
      it "logs a tagged error and flashes an error" do
        expect_find_seller_sections

        expect_pay_and_notify.
          and_raise("CHOOM")

        begin_log_capture

        post_create

        log_data = end_log_capture

        expect(response).to redirect_to(admin_financials_automate_seller_payments_path)
        expect(flash.alert).to eq "Payment failed"

        expect(log_data).to match(/PAYMENT_ERROR - #{controller.class.name}/)
        expect(log_data).to match(/While paying\/notifying Sellers on Automate plan: CHOOM/)
      end
    end

    context "when order_ids empty" do
      it "complains" do
        post :create, 
          seller_id: seller_id, 
          order_ids: [], 
          bank_account_id: bank_account_id,
          as_of_time: as_of_time
        expect(response).to redirect_to(admin_financials_automate_seller_payments_path)
        expect(flash.alert).to eq "No orders were selected to pay for"
      end
    end

  end

  def expect_log_tagged_error(tag, message_regexp)
    expect(Rails.logger).to receive(:tagged) do |*args,&block|
      expect(args[0]).to eq(tag)
      expect(Rails.logger).to receive(:error) do |err_message|
        expect(err_message).to match(message_regexp)
      end
      expect(block).to be  # ensure user passed a block to logger.tagged()
      block.call # ensure the block is called, since we've cut Rails' normal behavior out for the moment
    end
  end
end
