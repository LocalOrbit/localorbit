require "spec_helper"

describe Admin::Financials::AutomateMarketPaymentsController do
  include_context "the mini market"

  let(:market_sections) { [double("Seller Section 1"), double("Seller Section 2")] }
  let(:payment) { double "Payment" }

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
    it "provides all potentially payable markets by assigning MarketSections" do
      search_as_of = nil
      expect(::Financials::MarketPayments::Finder).to receive(:find_market_payment_sections) do |opts|
        search_as_of = opts[:as_of]
        market_sections
      end
      get :index
      expect(assigns[:as_of_time]).to be_within(5.seconds).of(Time.current)
      expect(search_as_of).to eq(assigns[:as_of_time])
      expect(assigns[:market_sections]).to eq market_sections
    end
  end

  describe "#create" do
    let (:order_ids) { %w(101 102 103) }
    let (:bank_account_id) { "999" }
    let (:market_id) { "300" }
    let (:as_of_time) { Time.zone.parse("Nov 16 2014 12:30pm").to_s }

    let(:market_fees_to_market) { ::Financials::PaymentMetadata::payment_config_for(:market_fees_to_market) }
    let(:delivery_fees_to_market) { ::Financials::PaymentMetadata::payment_config_for(:delivery_fees_to_market) }

    let(:market_fee_results) { 
      { status: :ok, payment: double("Market Fee Payment") }
    }
    let(:failing_market_fee_results) { 
      { status: :payment_failed, message: "Things went awry", payment: double("Failed Market Fee Payment") }
    }

    let(:delivery_fee_results) { 
      { status: :ok, payment: double("Delivery Fee Payment") }
    }
    let(:failing_delivery_fee_results) { 
      { status: :payment_failed, message: "He chose... poorly.", payment: double("Failed Delivery Fee Payment") }
    }

    def expect_find_market_sections
      expect(::Financials::MarketPayments::Finder).to receive(:find_market_payment_sections).
        with(as_of: Time.zone.parse(as_of_time),
             market_id: 300,
             order_id: [101,102,103]).
        and_return([market_sections.first])
    end

    def expect_pay_and_notify(payment_config)
      expect(::Financials::PaymentProcessor).to receive(:pay_and_notify).
        with(payment_config: payment_config,
             inputs: { market_section: market_sections.first,
                       bank_account_id: bank_account_id.to_i })
    end

    def post_create
      post :create, 
        market_id: market_id, 
        order_ids: order_ids, 
        bank_account_id: bank_account_id,
        as_of_time: as_of_time
    end

    it "re-loads the MarketSections filtered by selected Market and Orders then executes the payment" do
      expect_find_market_sections

      expect_pay_and_notify(market_fees_to_market).
        and_return(market_fee_results)

      expect_pay_and_notify(delivery_fees_to_market).
        and_return(delivery_fee_results)

      post_create

      expect(response).to redirect_to(admin_financials_automate_market_payments_path)
      expect(flash.notice).to eq "Payment recorded"
    end

    context "when PaymentProcesor returns skipped payment results for market fees" do
      let(:skipped_market_fee_results) { 
        { status: :payment_skipped, message: "Nothing to pay", payment_info: double("pmt info") }
      }

      let(:delivery_fee_results) { 
        { status: :ok, payment: double("Delivery Fee Payment") }
      }
      let(:skipped_delivery_fee_results) { 
        { status: :payment_skipped, message: "More nothing", payment_info: double("pmt info2") }
      }

      it "logs, and quietly provides success message" do
        expect_find_market_sections

        expect_pay_and_notify(market_fees_to_market).
          and_return(skipped_market_fee_results)

        expect_pay_and_notify(delivery_fees_to_market).
          and_return(skipped_delivery_fee_results)

        begin_log_capture

        post_create

        log_data = end_log_capture

        expect(response).to redirect_to(admin_financials_automate_market_payments_path)
        expect(flash.notice).to eq "Payment recorded"

        expect(log_data).to match(/payment_skipped/)
        expect(log_data).to match(/Nothing to pay/)
        expect(log_data).to match(/pmt info/)
        expect(log_data).to match(/More nothing/)
        expect(log_data).to match(/pmt info2/)
      end
    end

    context "when PaymentProcesor returns failure results for market fees" do
      it "complains via an alert" do
        expect_find_market_sections

        expect_pay_and_notify(market_fees_to_market).
          and_return(failing_market_fee_results)
        
        expect_pay_and_notify(delivery_fees_to_market).
          and_return(delivery_fee_results)

        begin_log_capture

        post_create

        log_data = end_log_capture

        expect(response).to redirect_to(admin_financials_automate_market_payments_path)
        expect(flash.alert).to eq "Payment failed"

        expect(log_data).to match(/PAYMENT_ERROR - #{controller.class.name}/)
        expect(log_data).to match(/Result status: :payment_failed/)
        expect(log_data).to match(/Things went awry/)
        expect(log_data).to match(/#{Regexp.escape(failing_market_fee_results[:payment].inspect)}/)
      end
    end

    context "when exception occurs" do
      
      it "logs a tagged error and flashes an error" do
        expect_find_market_sections

        expect_pay_and_notify(market_fees_to_market).
          and_return(market_fee_results)
        
        expect_pay_and_notify(delivery_fees_to_market).
          and_raise("BOOM")

        begin_log_capture

        post_create

        log_data = end_log_capture

        expect(response).to redirect_to(admin_financials_automate_market_payments_path)
        expect(flash.alert).to eq "Payment failed"

        expect(log_data).to match(/PAYMENT_ERROR - #{controller.class.name}/)
        expect(log_data).to match(/While paying\/notifying Market on Automate plan: BOOM/)
      end
    end

    context "when order_ids empty" do
      let(:order_ids) { [] }
      it "complains" do
        post_create
        expect(response).to redirect_to(admin_financials_automate_market_payments_path)
        expect(flash.alert).to eq "No orders were selected to pay for"
      end
    end

  end

end
