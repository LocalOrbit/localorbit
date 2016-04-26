class ProcessPaymentWithStripe
  include Interactor

  def perform
  end
  
#   def setup
#     context[:description]             ||= "Local Orbit"
#     context[:appears_on_statement_as] ||= "Local Orbit"
#   end

#   def perform
#     if payment.amount < 0
#       process_refund
#     elsif payment.payee
#       process_credit
#     else
#       process_debit
#     end
#   rescue => error
#     handle_error(error)

#     context[:error] = error
#     context.fail!
#   end

#   protected

#   def handle_error(error)
#     updates = {status: "failed"}
#     if (error_code = error.try(:category_code).presence)
#       updates[:note] = "Error: #{error_code}"
#       updates[:note] = "#{payment.note} #{updates[:note]}" if payment.note.present?
#     end
#     payment.update_columns(updates)
#   end

#   def process_credit
#     balanced_account = Balanced::BankAccount.find(payment.bank_account.balanced_uri)
#     credit = balanced_account.credit(transaction_params(false))

#     payment.update_attribute(:balanced_uri, credit.uri)
#   end

#   def process_debit
#     customer = payment.payer.balanced_customer
#     debit = customer.debit(transaction_params(true))

#     payment.update_attributes(balanced_uri: debit.uri)
#   end

#   def process_refund
#     debit = payment.parent.balanced_transaction
#     amount = -1 * ::Financials::MoneyHelpers.amount_to_cents(payment.amount)
#     refund = debit.refund(amount: amount)

#     payment.update_attributes(balanced_uri: refund.uri)
#   end

#   def transaction_params(with_source)
#     params = {
#       amount:                  ::Financials::MoneyHelpers.amount_to_cents(payment.amount),
#       description:             context[:description],
#       appears_on_statement_as: context[:appears_on_statement_as]
#     }
#     params[:source_uri] = payment.bank_account.balanced_uri if with_source
#     params
#   end
end
