class CreateManagedStripeAccountForMarket
  include Interactor

  def setup
  end

  def perform
    market = context[:market]
    raise "NOT IMPLEMENTED"
  end

  # def stripe_customer_info
  #   {
  #     description: entity.name,
  #     metadata: {
  #       "lo.entity_id" => entity.id,
  #       "lo.entity_type" => entity.class.name.underscore
  #     }
  #   }
  # end
end
