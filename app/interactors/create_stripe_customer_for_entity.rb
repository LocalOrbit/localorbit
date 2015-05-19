class CreateStripeCustomerForEntity
  include Interactor

  def setup
    context[:entity] ||= context[:market] || context[:organization]
  end

  def perform
    entity = context[:entity]
    if entity.stripe_customer_id.nil?
      customer = Stripe::Customer.create(stripe_customer_info)
      entity.update_attribute(:stripe_customer_id, customer.id)
      context[:stripe_customer] = customer
    else
      context[:stripe_customer] = Stripe::Customer.retrieve(entity.stripe_customer_id)
    end
  end

  def stripe_customer_info
    {
      description: entity.name,
      metadata: {
        "lo.entity_id" => entity.id,
        "lo.entity_type" => entity.class.name.underscore
      }
    }
  end
end
