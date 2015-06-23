require 'spec_helper'

describe ErrorReporting do
  subject { described_class }

  describe ".interpret_generic_exception" do
    let(:error) { begin; raise "FOOMP!"; rescue Exception => e; e; end }

    it "generates a friendly error reporting structure" do
      error_info = ErrorReporting.interpret_generic_exception(error, "Dang")

      SchemaValidation.validate!(ErrorReporting::Schema::ErrorInfo, error_info)

      expect(error_info[:application_error_message]).to eq "Dang"

      de = error_info[:honeybadger_exception]
      expect(de.class).to be DescriptiveError
      expect(de.data).to eq(
        exception: {
          class_name: "RuntimeError",
          message: "FOOMP!",
          origin: error.backtrace.first
        }
      )
    end

    context "when the error has a cause" do
      let(:error2) { begin; raise "FOOMP!"; rescue Exception => e; begin; raise "CLUNK!"; rescue Exception => e2; e2; end; end }
      it "expands the cause exception in the error data" do
        error_info = ErrorReporting.interpret_generic_exception(error2, "Drat")
        
        SchemaValidation.validate!(ErrorReporting::Schema::ErrorInfo, error_info)

        expect(error_info[:application_error_message]).to eq "Drat"

        de = error_info[:honeybadger_exception]
        expect(de.class).to be DescriptiveError
        expect(de.data).to eq(
          exception: {
            class_name: "RuntimeError",
            message: "CLUNK!",
            origin: error2.backtrace.first,
            cause: {
              class_name: "RuntimeError",
              message: "FOOMP!",
              origin: error2.cause.backtrace.first
            }
          }
        )
      end

    end
  end


  describe ".interpret_stripe_error" do
    let(:stripe_error) {
      captured = nil
      VCR.turn_off!
      begin
        Stripe::Charge.create
      rescue Exception => e
        captured = e
      end
      VCR.turn_on!
      captured
    }

    it "provides an additional :error_data field on the DescriptiveException data structure" do
      error_info = ErrorReporting.interpret_stripe_error(stripe_error)
      expect(error_info[:application_error_message]).to eq "Payment processor error."

      de = error_info[:honeybadger_exception]
      expect(de.class).to be DescriptiveError
      expect(de.data).to eq(
        exception: {
          class_name: "Stripe::InvalidRequestError",
          message: "Must provide source or customer.",
          origin: stripe_error.backtrace.first,
          cause: {
            class_name: "RestClient::BadRequest",
            message: "400 Bad Request",
            origin: stripe_error.cause.backtrace.first,
          }
        },
        error_data: {
          error: {
            type: "invalid_request_error",
            message: "Must provide source or customer."
          }
        }
      )

      error_info2 = ErrorReporting.interpret_stripe_error(stripe_error, "Roar")
      expect(error_info2[:application_error_message]).to eq "Roar"

    end
  end

  describe ".interpet_error" do
    let(:error_info) {{
      honeybadger_exception: RuntimeError.new,
      application_error_message: "the error message"
    }}

    context "when given a Stripe error" do
      let (:error) { Stripe::StripeError.new }

      it "delegates to .interpret_stripe_error" do
        expect(ErrorReporting).to receive(:interpret_stripe_error).with(error,nil).and_return(error_info)
        info = ErrorReporting.interpret_exception(error)
        expect(info).to eq error_info
      end
    end

    context "when given any ol' exception" do 
      let (:error) { RuntimeError.new("OUCH") }

      it "delegates to .interpret_generic_exception" do
        expect(ErrorReporting).to receive(:interpret_generic_exception).with(error,nil).and_return(error_info)
        info = ErrorReporting.interpret_exception(error)
        expect(info).to eq error_info
      end
    end
  end

end

