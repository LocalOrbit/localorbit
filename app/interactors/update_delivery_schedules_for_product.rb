class UpdateDeliverySchedulesForProduct
  include Interactor

  def perform
    require_in_context :product

    markets = product.organization.all_markets

    product.delivery_schedules = if product.use_all_deliveries?
      DeliverySchedule.where(market: markets).visible
    else
      product.delivery_schedules.where(market: markets)
    end
  end

end
