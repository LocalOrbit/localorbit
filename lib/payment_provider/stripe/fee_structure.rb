module PaymentProvider
  module Stripe
    class FeeStructure

      CreditCard = {
        style:    :rate_plus_flat_fee,
        rate:     "0.029".to_d,
        flat_fee: "0.30".to_d,
      }

      ACH = {
        style:    :rate_plus_flat_fee_capped,
        rate:     "0.01".to_d,
        flat_fee: "0.30".to_d,
        cap:      "8.0".to_d
      }


      class << self

        def estimate_credit_card_processing_fee(amount_in_cents)
          (amount_in_cents * CreditCard[:rate]) + CreditCard[:flat_fee]
        end

        def estimate_ach_processing_fee(amount_in_cents)
          [
            (amount_in_cents * ACH[:rate]) + ACH[:flat_fee],
            ACH[:cap]
          ].min
        end

      end
    end

  end
end
