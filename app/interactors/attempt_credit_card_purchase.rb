class AttemptCreditCardPurchase
  include Interactor

  def perform
    if order_params["payment_method"] == 'credit card'
      begin
        card = cart.organization.bank_accounts.find(order_params["credit_card"])
        balanced_card = Balanced::Card.find(card.balanced_uri)

        amount = (cart.total * 100).to_i #USD in cents

        hold = balanced_card.hold(amount: amount, description: "LocalOrbit market purchase")

        context[:payment] = Payment.create(
          payment_type: 'credit card',
          amount: cart.total,
          status: "pending",
          payment_uri: hold.uri
        )

        if !context[:payment].persisted?
          hold.void
          context.fail!
        end

      rescue
        context[:order] = Order.new(credit_card: order_params["credit_card"])
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
