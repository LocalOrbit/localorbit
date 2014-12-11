module Financials

  class PaymentExecutor
    cattr_accessor :capture_payments, :previously_captured_payments
    self.previously_captured_payments = []
    self.capture_payments = false

    class << self
      def execute_credit(payment: nil, payment_attributes: nil, description: nil)
        if payment.nil?
          if payment_attributes
            payment = Payment.create!(payment_attributes)
          else
            raise "Must provide either :payment or :payment_attributes keyword arg"
          end
        end

        begin
          if capture_payments
            previously_captured_payments << {payment:payment, description:description}
            return payment
          end

          if bank_account = payment.bank_account
            if balanced_uri = payment.bank_account.balanced_uri
              balanced_account = Balanced::BankAccount.find(balanced_uri)
              credit = balanced_account.credit(
                amount:                  Financials::MoneyHelpers.amount_to_cents(payment.amount),
                appears_on_statement_as: payment.market.try(:on_statement_as),
                description:             description
              )

              # Amend the Payment record with a link to the Balanced transaction:
              payment.update_column(:balanced_uri, credit.uri)
            else
              handle_payment_error payment, "BankAccount not linked to a Balanced account: balanced_uri not set"
            end
          else
            handle_payment_error payment, "No BankAccount associated with this Payment"
          end

          payment
        rescue Exception => e 
          handle_payment_error payment, e.message, e.try(:category_code)
          payment
        end
      end

      def handle_payment_error(payment, error_message, category_code=nil)
        note = "ERROR: #{error_message}"
        if category_code
          note = "#{note} - Error Code: #{category_code}"
          if payment.note.present?
            note = "#{payment.note} - #{note}"
          end
        end
        payment.update_columns(
          status: "failed",
          note:   note
        )
      end
    end
  end
end
          
