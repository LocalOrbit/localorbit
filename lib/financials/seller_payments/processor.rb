module Financials
  module SellerPayments
    class Processor
      class << self
        include Financials::SellerPayments::Schema

        def pay_and_notify_seller(seller_section: seller_section, bank_account_id: bank_account_id)
          # Load payment-relevant data pertaining to the targeted paument
          payment_info = Financials::SellerPayments::PaymentConverter.seller_section_to_payment_info(
            seller_section: seller_section,
            bank_account_id: bank_account_id)

          # Create a Payment record:
          payment = Financials::PaymentBuilder.payment_to_seller(payment_info: payment_info)

          # Execute payment
          payment = Financials::PaymentExecutor.execute_credit(
            payment: payment, 
            description: "Payment to Seller on 'Automate'")

          if payment.status != 'failed'
            # Notify sellers of the payment
            Financials::PaymentNotifier.seller_payment_received(payment: payment)
          end

          return payment
        end
      end
    end
  end
end
