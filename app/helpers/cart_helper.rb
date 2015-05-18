module CartHelper
  def allow_payment_option?(kind, market, organization)
    case kind
    when :purchase_order
      return market.allow_purchase_orders? and organization.allow_purchase_orders?

    when :ach
      return (PaymentProvider.supports_payment_method?(market.payment_provider, "ach") and
              market.allow_ach? and 
              organization.allow_ach?)

    when :credit_card
      return (PaymentProvider.supports_payment_method?(market.payment_provider, "credit card") and
              market.allow_credit_cards? and 
              organization.allow_credit_cards?)

    else
      raise "Don't know how to allow_payment_option? for #{kind.inspect}"
    end
  end
end
