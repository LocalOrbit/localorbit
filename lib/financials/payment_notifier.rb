module Financials
  class PaymentNotifier
    class << self
      def seller_payment_received(payment:)
        if payment and (seller_organization = payment.payee)
          _notify_payment_received(payment, seller_organization.users)
        end
      end

      def market_payment_received(payment:)
        if payment and (market = payment.payee)
          _notify_payment_received(payment, market.managers)
        end
      end

      private

      def _notify_payment_received(payment, users)
        if users.present?
          recipients = users.map(&:pretty_email)
          ::PaymentMailer.delay.payment_received(recipients, payment.id) 
        end
        nil
      end
    end
  end
end
