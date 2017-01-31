module Quickbooks
  class Payment
    class << self
      def create_payment(order, session)

        payment = Quickbooks::Model::Payment.new
        payment.customer_id = order.organization.qb_org_id
        payment.txn_date = Date
        payment.total = order.total_cost
        payment.private_note = "Associated Stripe Transactions: #{order.payments.map(&:stripe_id).join(', ')}"

        line_item = Quickbooks::Model::Line.new
        line_item.amount = order.total_cost
        line_item.invoice_id = order.qb_ref_id
        payment.line_items << line_item

        service = Quickbooks::Service::Payment.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.create(payment)
      end
    end
  end
end