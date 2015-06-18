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

end

