class ProcessRefundWithBalanced
  include Interactor

  def setup
    context[:description]             ||= "Local Orbit"
    context[:appears_on_statement_as] ||= "Local Orbit"
  end

  def perform
    process_refund if payment

  rescue => error
    handle_error(error)

    context[:error] = error
    context.fail!
  end

  protected

  def handle_error(error)
    updates = {status: "failed"}
    if error_code = error.try(:category_code).presence
      updates[:note] = "Error: #{error_code}"
      updates[:note] = "#{payment.note} #{updates[:note]}" if payment.note.present?
    end
    refund_payment.update_columns(updates)
  end

  def process_refund
    debit = Balanced::debit.find(payment.balanced_uri)
    debit.refund(amount) if debit
  end

  def transaction_params(with_source)
    params = {
      amount:                  (payment.amount * 100).to_i,
      description:             context[:description],
      appears_on_statement_as: context[:appears_on_statement_as]
    }
    params[:source_uri] = payment.bank_account.balanced_uri if with_source
    params
  end
end
