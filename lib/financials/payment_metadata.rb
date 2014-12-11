module Financials
  module PaymentMetadata
    include Financials::Schema

    ConfigSchema = {
      description: String,
      payment_notifier: Symbol, # a class method on Financials::PaymentNotifier
      payment_info_converter: Symbol, # a class method on Financials::PaymentInfoConverter
      payment_base_attrs: {
        payment_type:   PaymentTypeLower,
        payment_method: PaymentMethodLower,
        status:         PaymentStatusLower
      }
    }

    Configs = {
      net_to_seller: {
        description: "Payment to Seller on 'Automate'",
        payment_base_attrs: {
          payment_type:   "seller payment",
          payment_method: "ach",
          status:         "pending"
        },
        payment_info_converter: :seller_net_payment_info,
        payment_notifier: :seller_payment_received,
      },

      market_fees_to_market: {
        description: "Market Fee payment to Market on 'Automate'",
        payment_base_attrs: {
          payment_type:   "hub fee",
          payment_method: "ach",
          status:         "pending"
        },
        payment_info_converter: :market_hub_fee_payment_info,
        payment_notifier: :market_payment_received,
      },

      delivery_fees_to_market: {
        description: "Delivery Fee payment to Market on 'Automate'",
        payment_base_attrs: {
          payment_type:   "delivery fee",
          payment_method: "ach",
          status:         "pending"
        },
        payment_info_converter: :market_delivery_fee_payment_info,
        payment_notifier: :market_payment_received,
      },
    }


    def self.payment_config_for(kind_of_payment)
      config = Configs[kind_of_payment] || raise("There is no Payment metadata configured for #{kind_of_payment.inspect}")
      SchemaValidation.validate!(ConfigSchema, config)
    end
  end
end
