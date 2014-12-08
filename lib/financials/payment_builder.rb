module Financials
  class PaymentBuilder
    def self.payment_to_seller(payment_info:)
      SchemaValidation.validate!(Financials::SellerPayments::Schema::PaymentInfo, payment_info)

      Payment.create!(
        payment_info.merge(
          payment_type:   "seller payment",
          payment_method: "ach",
          status:         "pending"))
    end
  end
end
