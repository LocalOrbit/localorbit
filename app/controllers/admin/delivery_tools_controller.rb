class Admin::DeliveryToolsController < AdminController
  def index
    @upcoming_deliveries = current_market.delivery_schedules.map do |ds|
      ds.deliveries.where("deliver_on > :time", time: Time.current).
      joins(orders: {items: :product}).where(products: {organization_id: current_organization.id})
    end.flatten
  end
end
