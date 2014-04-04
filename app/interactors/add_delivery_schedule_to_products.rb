class AddDeliveryScheduleToProducts
  include Interactor

  def perform
    market.organizations.map(&:products).flatten.each do |product|
      product.delivery_schedules << delivery_schedule if product.use_all_deliveries
    end
  end
end
