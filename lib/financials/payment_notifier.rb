module Financials
  class PaymentNotifier
    class << self
      def seller_payment_received(payment:, async:true)
        if payment and (seller_organization = payment.payee)
          _notify_payment_received(payment, seller_organization.users, async)
        end
      end

      def market_payment_received(payment:, async:true)
        if payment and (market = payment.payee)
          _notify_payment_received(payment, market.managers, async)
        end
      end

      private

      def _notify_payment_received(payment, users, async)
        if users.present?
          recipients = users.map(&:pretty_email)
          if async
            ::PaymentMailer.delay.payment_received(recipients, payment.id) 
          else
            ::PaymentMailer.payment_received(recipients, payment.id).deliver
          end
        end
        nil
      end
    end
  end
end
