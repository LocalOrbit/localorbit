module PaymentProvider
  class Stripe
    CreditCardFeeStructure = SchemaValidation.validate!(FeeEstimator::Schema::BasePlusRate,
      style: :base_plus_rate,
      base:  30,
      rate:  "0.029".to_d, # 2.9% of total
    )

    class << self
      def id; :stripe; end

      def supported_payment_methods
        [ "credit card" ]
      end

      def place_order(buyer_organization:, user:, order_params:, cart:)
        PlaceStripeOrder.perform(payment_provider: :stripe, 
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
        
        return ::Stripe::Charge.create(
          amount: amount_in_cents, 
          currency: 'usd', 
          source: source, 
          customer: customer,
          destination: destination, 
          statement_descriptor: descriptor,
          application_fee: fee_in_cents)
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
        raise "add_payment_method not implemented for PaymentProvider::Stripe!"
        # params = {
        #   entity: entity, 
        #   bank_account_params: bank_account_params, 
        #   representative_params: representative_params
        # }
        # if type == "card"
        #   AddBalancedCreditCardToEntity.perform(params)
        # else
        #   AddBalancedBankAccountToEntity.perform(params)
        # end
      end

      private 
      
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
