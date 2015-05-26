class SetPaymentProvidersToBalanced < ActiveRecord::Migration

  class Market < ActiveRecord::Base
  end
  class Payment < ActiveRecord::Base
  end
  class Order < ActiveRecord::Base
  end

  def up
    ::SetPaymentProvidersToBalanced::Market.update_all payment_provider: 'balanced'
    ::SetPaymentProvidersToBalanced::Payment.update_all payment_provider: 'balanced'
    ::SetPaymentProvidersToBalanced::Order.update_all payment_provider: 'balanced'
  end
end
