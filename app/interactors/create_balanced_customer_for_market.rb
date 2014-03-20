class CreateBalancedCustomerForMarket
  include Interactor

  def perform
    customer = Balanced::Customer.new(balanced_customer_info).save
    market.update_attribute(:balanced_customer_uri, customer.uri)
  end

  def balanced_customer_info
    {
      name: market.name,
      meta: {
        market_id: market.id,
        market_name: market.name
      }
    }
  end
end
