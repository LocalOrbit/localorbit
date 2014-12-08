module Financials
  class PaymentNotifier
    class << self
      def seller_payment_received(payment:)
        if payment and (seller_organization = payment.payee)
          users = seller_organization.users
          if users.present?
            recipients = users.map(&:pretty_email)
            ::PaymentMailer.delay.payment_received(recipients, payment.id) 
          end
        end
        nil
      end
    end
  end
end
