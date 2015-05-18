module PaymentProvider
  class Stripe
    CreditCardFeeStructure = SchemaValidation.validate!(FeeEstimator::Schema::BasePlusRate,
      style: :base_plus_rate,
      base:  30,
      rate:  "0.029".to_d, # 2.9% of total
    )

    module CardSchema
      Base = RSchema.schema {{
        name: String,
        bank_name: String,
        account_type: String,
        last_four: String,
        expiration_month: String,
        expiration_year: String,
        _?(:notes) => String,
      }}

      SubmittedParams = RSchema.schema do
        Base.merge(
          _?(:id) => String,
          _?(:save_for_future) => String,
          :stripe_tok => String
        )
      end

      NewParams = RSchema.schema do
        Base.merge(
          _?(:stripe_id) => String,
          _?(:deleted_at) => Time
        )
      end
    end

    class << self
      def id; :stripe; end

      def supported_payment_methods
        [ "credit card" ]
      end

      def addable_payment_methods
        [ "credit card" ]
      end

      def place_order(buyer_organization:, user:, order_params:, cart:)
        PlaceStripeOrder.perform(payment_provider: self.id.to_s, 
                                 entity: buyer_organization, 
                                 buyer: user,
                                 order_params: order_params, 
                                 cart: cart)
      end

      def translate_status(charge:, amount:nil, payment_method:nil)
        if charge.nil? 
          if amount == 0 and payment_method == "credit card"
            # Sigh.  The overarching payment processing scheme is to treat CC payments of $0.00 as instantly "paid" 
            # without actually executing a transaction with the provider...
            return "paid"
          else
            # ...but generally, missing charge is a sign of failure:
            return "failed"
          end
        end

        case charge.status
        when 'pending'   
          'pending'
        when 'succeeded' 
          'paid'
        else
          'failed'
        end
      end

      def charge_for_order(amount:, bank_account:, market:, order:, buyer_organization:)
        amount_in_cents = ::Financials::MoneyHelpers.amount_to_cents(amount)
        customer = buyer_organization.stripe_customer_id
        source = bank_account.stripe_id
        destination = market.stripe_account_id
        descriptor = market.on_statement_as
        
        fee_in_cents = PaymentProvider::FeeEstimator.estimate_payment_fee CreditCardFeeStructure, amount_in_cents

        # TODO: once we support ACH via Stripe, this branch will be needed for an alternate estimate of ACH fees:
        # fee_in_cents = if bank_account.credit_card?
        #                  estimate_credit_card_processing_fee_in_cents(amount_in_cents)
        #                else
        #                  estimate_ach_processing_fee_in_cents(amount_in_cents)
        #                end
        
        charge = ::Stripe::Charge.create(
          amount: amount_in_cents, 
          currency: 'usd', 
          source: source, 
          customer: customer,
          destination: destination, 
          statement_descriptor: descriptor,
          application_fee: fee_in_cents)

        # Pin some order metadata on the Stripe::Payment object that appears in the managed account:
        transfer = ::Stripe::Transfer.retrieve(charge.transfer)
        payment = ::Stripe::Charge.retrieve(transfer.destination_payment, {stripe_account: transfer.destination})
        payment["metadata"]["lo.order_id"] = order.id.to_s
        payment["metadata"]["lo.order_number"] = order.order_number
        payment.save

        return charge
      end

      def fully_refund(charge:nil, payment:, order:)
        charge ||= ::Stripe::Charge.retrieve(payment.stripe_id)
        charge.refunds.create(refund_application_fee: true,
                              reverse_transfer: true,
                              metadata: { 'lo.order_id' => order.id,
                                          'lo.order_number' => order.order_number })
      end

      def store_payment_fees(order:)
        total_fee = order.payments.where(payment_type: 'order').sum(:stripe_payment_fee)
        total_fee_cents = ::Financials::MoneyHelpers.amount_to_cents(total_fee)
        fees = distribute_fee_amongst_order_items(total_fee_cents, order)
        
        fee_payer = order.market.credit_card_payment_fee_payer
        order.items.each do |item|
          fee_cents = fees[item.id]
          fee = if fee_cents.nil?
                  0.to_d
                else
                  ::Financials::MoneyHelpers.cents_to_amount(fee_cents)
                end
          item.update :"payment_#{fee_payer}_fee" => fee
        end
        nil
      end

      def create_order_payment(charge:, market_id:, bank_account:, payer:,
                                  payment_method:, amount:, order:, status:)
        stripe_id = if charge then charge.id else nil end

        Payment.create(
          payment_provider: self.id.to_s,
          market_id: market_id,
          bank_account: bank_account,
          payer: payer,
          payment_method: payment_method,
          amount: amount,
          payment_type: 'order',
          orders: [order],
          status: status,
          stripe_id: stripe_id,
          stripe_payment_fee: get_stripe_application_fee_for_charge(charge)
        )
      end

      def create_refund_payment(charge:, market_id:, bank_account:, payer:,
                                    payment_method:, amount:, order:, status:, refund:, parent_payment:)
        stripe_id = charge ? charge.id : nil
        stripe_refund_id = refund ? refund.id : nil

        payment = Payment.create(
          payment_provider: self.id.to_s,
          market_id: market_id,
          bank_account: bank_account,
          payer: payer,
          payment_method: payment_method,
          amount: amount,
          payment_type: 'order refund',
          orders: [order],
          parent_id: parent_payment.id,
          status: status,
          stripe_id: stripe_id,
          stripe_refund_id: stripe_refund_id
        )
        parent_payment.update stripe_payment_fee: get_stripe_application_fee_for_charge(charge)
        return payment
      end

      def find_charge(payment:)
        ::Stripe::Charge.retrieve(payment.stripe_id)
      end

      def refund_charge(charge:, amount:, order:)
        amount_in_cents = ::Financials::MoneyHelpers.amount_to_cents(amount)
        charge.refunds.create(refund_application_fee: true,
                              reverse_transfer: true,
                              amount: amount_in_cents,
                              metadata: { 
                                'lo.order_id' => order.id,
                                'lo.order_number' => order.order_number 
                              })
      end

      def add_payment_method(type:, entity:, bank_account_params:, representative_params:)
        if type == "card"

          AddStripeCreditCardToEntity.perform(
            entity: entity, 
            bank_account_params: bank_account_params, 
            representative_params: representative_params)
        else
          raise "PaymentProvider::Stripe doesn't support adding payment methods of type #{type.inspect}; only 'card' supported currently."
        end
      end

      #
      #
      # NON-PaymentProvider interface:
      #
      #

      def create_stripe_card_for_stripe_customer(stripe_customer:nil,stripe_customer_id:nil, stripe_tok:)
        customer = stripe_customer || ::Stripe::Customer.retrieve(stripe_customer_id)
        credit_card = customer.sources.create(source: stripe_tok)
        credit_card
      end

      def order_ids_for_market_payout_transfer(transfer_id:, stripe_account_id:)

        order_ids = enumerate_transfer_transactions(transfer_id: transfer_id, stripe_account_id: stripe_account_id).map do |transaction|
          if metadata = transaction.try(:source).try(:metadata)
            order_id = metadata['lo.order_id']
            order_id.to_i unless order_id.nil?
          end
        end
        order_ids.compact.uniq
      end

      def create_market_payment(transfer_id:, market:, order_ids:, status:, amount:)
        Payment.create!(
          payment_provider: self.id.to_s,
          payment_type:   "market payment",
          amount:         amount,
          status:         status,
          stripe_transfer_id: transfer_id,
          market:         market,
          payee:          market,
          bank_account:   nil,
          order_ids:      order_ids,
          payment_method: "ach"
        )
      end

      private 

      def enumerate_transfer_transactions(transfer_id:, stripe_account_id:)
        response = ::Stripe::BalanceTransaction.all(
          {limit: 100, type: 'payment', expand: ['data.source'], 
            transfer: transfer_id}, {stripe_account: stripe_account_id})

        response.data
      end

      
      def distribute_fee_amongst_order_items(total_fee_cents, order)
        order_total_cents = ::Financials::MoneyHelpers.amount_to_cents(order.gross_total)

        LargestRemainder.distribute_shares(
          to_distribute: total_fee_cents,
          total:         order_total_cents,
          items:         order.usable_items.inject({}) do |memo,item|
                           memo[item.id] = ::Financials::MoneyHelpers.amount_to_cents(item.gross_total)
                           memo
                         end
        )
      end

      def get_stripe_application_fee_for_charge(charge)
        return "0".to_d unless charge

        app_fee = ::Stripe::ApplicationFee.retrieve(charge.application_fee)
        if app_fee
          ::Financials::MoneyHelpers.cents_to_amount(app_fee.amount - app_fee.amount_refunded)
        else
          "0".to_d
        end
      end

    end
    
  end
end
