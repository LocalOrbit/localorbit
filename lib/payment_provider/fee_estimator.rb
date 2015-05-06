module PaymentProvider
  module FeeEstimator
    module Schema
      Cents = Integer
      Rate  = BigDecimal

      BasePlusRate = RSchema.schema {{
        style: enum([:base_plus_rate]),
        base: Cents,
        rate: Rate
      }}

      FeeStructure = RSchema.schema { either(BasePlusRate) }
    end

    class << self
      def estimate_payment_fee(fee_structure, amount_in_cents)
        SchemaValidation.validate!(FeeEstimator::Schema::FeeStructure, fee_structure)

        case fee_structure[:style]
        when :base_plus_rate
          fee_structure[:base] + (amount_in_cents * fee_structure[:rate]).round 
        else
          raise "Cannot estimate fee on #{amount_in_cents} cents; fee structure style #{fee_structure[:style]} not supported."
        end
      end
    end
  end
end
