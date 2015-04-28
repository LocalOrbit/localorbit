class CreateStripeCustomerForEntity
  include Interactor

  def setup
    context[:entity] ||= context[:market] || context[:organization]
  end

  def perform
    if entity.balanced_customer_uri.nil?
      customer = Balanced::Customer.new(balanced_customer_info).save
      entity.update_attribute(:balanced_customer_uri, customer.uri)
    end
  end

  def balanced_customer_info
    {
      name: entity.name,
      meta: {
        entity_id: entity.id,
        entity_name: entity.name,
        entity_type: entity.class.name.underscore
      }
    }
  end
end
