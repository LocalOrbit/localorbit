class AttemptAchPurchase
  include Interactor


  def perform
    if order_params["payment_method"] == 'ach'
      begin
        bank_account = cart.organization.bank_accounts.find(order_params["bank_account"])
        balanced_customer = Balanced::Customer.find(cart.organization.balanced_customer_uri)

        amount = (cart.total * 100).to_i #USD in cents

        debit = balanced_customer.debit(amount: amount, description: "#{cart.market.name} purchase", source_uri: bank_account.balanced_uri)

        context[:payment] = Payment.create(
          payer: buyer,
          payment_method: 'ach',
          amount: cart.total,
          status: "pending",
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
