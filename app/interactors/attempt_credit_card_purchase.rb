class AttemptCreditCardPurchase
  include Interactor

  def perform
    if order_params["payment_method"] == 'credit card'
      begin
        card = cart.organization.bank_accounts.find(order_params["credit_card"])
        balanced_customer = Balanced::Customer.find(cart.organization.balanced_customer_uri)

        amount = (cart.total * 100).to_i #USD in cents

        debit = balanced_customer.debit(
          amount: amount,
          source_uri: card.balanced_uri,
          description: "#{cart.market.name} purchase"
        )

        context[:payment] = Payment.create(
          payer: buyer,
          payment_method: 'credit card',
          amount: cart.total,
          status: "paid",
          balanced_uri: debit.uri
        )

        if !context[:payment].persisted?
          debit.void
          context.fail!
        end

      rescue Exception => e
        Honeybadger.notify_or_ignore(e) unless Rails.env.test? || Rails.env.development?

        context[:order] = Order.new(credit_card: order_params["credit_card"])
        context[:order].errors.add(:credit_card, "Payment processor error.")
        context.fail!
      end
    end
  end

  def rollback
    if order_params["payment_method"] == 'credit card' && context[:payment]
      Balanced::Hold.find(payment.payment_uri).void
      context.delete(:payment)
    end
  end
end
