class Admin::IndividualPackListsController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate

    ids = current_user.managed_organizations.map(&:id)
    order_items = OrderItem.joins(:order, :product).where(products: {organization_id: ids}, orders: {delivery_id: @delivery.id})
    
    @pack_lists = order_items.inject({}) do |result, item|
      seller = item.product.organization
      result[seller] ||= {}
      result[seller][item.order] ||= []
      result[seller][item.order] << item
      result
    end
  end
end
