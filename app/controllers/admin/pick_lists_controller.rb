class Admin::PickListsController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate
    organization_id = current_organization.id

    order_items = @delivery.orders.joins(items: :product).
      where( products: { organization_id: organization_id}).includes(:items).
      map(&:items).flatten.group_by(&:product)

    @line_items = []
    order_items.keys.each do |product|
      ordered = order_items[product]

      total = ordered.inject(0) do |memo, line|
        memo += line.quantity
      end

      @line_items << OpenStruct.new(
        name: product.name,
        total_sold: total,
        unit: total == 1 ? product.unit.singular : product.unit.plural,
        buyers: ordered.map do |line|
          OpenStruct.new(
            name: line.order.organization.name,
            quantity: line.quantity,
            lots: line.lots.select {|lot| lot.number.present? }
          )
        end
      )
    end
  end
end
