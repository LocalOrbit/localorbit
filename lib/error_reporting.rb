module ErrorReporting
  module Schema
    BacktraceItem = String
    Backtrace = [ BacktraceItem ]

    ErrorInfo = {
      honeybadger_exception: Exception,
      application_error_message: String
    }

    ExceptionInfo = RSchema.schema {{
      class_name: String,
      message: String,
      origin: maybe(BacktraceItem)
    }}
    RSchema.schema do
      # In order to define ExceptionInfo in terms of ExceptionInfo,
      # we have to add it to the schema AFTER the fact:
      ExceptionInfo[_?(:cause)] = maybe(ExceptionInfo)
    end
  end

  class << self

    def interpret_exception(e, prefix=nil, data=nil)

      info = case e
             when ::Stripe::StripeError
               interpret_stripe_error(e,prefix,data)
             else
               interpret_generic_exception(e,prefix,data)
             end

      SchemaValidation.validate!(Schema::ErrorInfo, info)
    end

    def interpret_generic_exception(e,message=nil,data=nil)
      message ||= "Unexpected error"

      data ||= {}
      data = data.merge(
        exception: exception_to_info(e),
      )

      honeybadger_exception = DescriptiveError.new(message: message, data: data, root: e)

      {
        honeybadger_exception: honeybadger_exception,
        application_error_message: message
      }
    end

    def interpret_stripe_error(e,application_error_message=nil,data=nil)
      application_error_message ||= "Payment processor error."
      json_error_data = nil

      technical_message = application_error_message
      if e.respond_to?(:json_body)
        json_error_data = e.json_body
        if json_error_data
          if err = json_error_data[:error]
            technical_message = err[:message]
          end
        end
      end

      data ||= {}
      data = data.merge(
        exception: exception_to_info(e),
        error_data: json_error_data
      )

      honeybadger_exception = DescriptiveError.new(message: technical_message, data: data, root: e)

      {
        honeybadger_exception: honeybadger_exception,
        application_error_message: application_error_message
      }
    end

    def exception_to_info(e)
      return nil if e.nil?
      exception_info = {
        class_name: e.class.name,
        message: e.message,
        origin: (e.backtrace ? e.backtrace.first : nil)
      }

      if e.cause
        exception_info[:cause] = exception_to_info(e.cause)
      end
      
      SchemaValidation.validate!(Schema::ExceptionInfo, exception_info)
    end
  end
end

