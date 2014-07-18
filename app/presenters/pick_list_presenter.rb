class PickListPresenter
  def self.build(current_user, current_organization, delivery)
    order_items = OrderItem.where(delivery_status: "pending", orders: {delivery_id: delivery.id}).
      eager_load(:order, product: :organization).
      order("organizations.name, products.name").
      preload(order: :organization)

    if !(current_user.admin? || current_user.market_manager?)
      order_items = order_items.where(products: {organization_id: current_organization.id})
    end

    order_items.group_by {|item| item.product.organization_id }.map do |_, items|
      new(items)
    end
  end

  def initialize(items)
    @items  = items
    @seller = items.first.product.organization
  end

  def products
    @products ||= @items.group_by(&:product_id).map {|_, items| PickListProduct.new(items) }
  end

  def seller_name
    @seller.name
  end

  def seller_ship_from_address
    @seller_ship_from_address ||= @seller.decorate.ship_from_address
  end

  class PickListProduct
    def initialize(items)
      @items   = items
      @product = @items.first.product
    end

    def name
      @product.name
    end

    def total_sold
      @total_sold ||= @items.sum(&:quantity)
    end

    def unit
      @unit ||= total_sold == 1 ? @product.unit_singular : @product.unit_plural
    end

    def buyers
      @buyers ||= @items.sort {|a,b| a.order.organization.name.casecmp(b.order.organization.name) }.map do |item|
        OpenStruct.new(
          name:     item.order.organization.name,
          quantity: item.quantity,
          lots:     item.lots.select {|lot| lot.number.present? }
        )
      end
    end

    def first_buyer
      @first_buyer ||= buyers.first
    end

    def remaining_buyers
      @remaining_buyers ||= buyers[1..-1]
    end
  end
end
