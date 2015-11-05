class SellerOrder
  include ActiveModel::Model
  include DeliveryStatus
  include OrderPresenter

  delegate :display_delivery_or_pickup,
    :display_delivery_address,
    :delivery_id,
    :delivery_status,
    :organization_id,
    :credit,
    :sellers,
    :errors,
    to: :@order

  attr_reader :seller

  def initialize(order, seller)
    @order = order.decorate
    @seller = seller
    if @seller.is_a?(User)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => @seller.managed_organization_ids_including_deleted).order("order_items.name")
    elsif @seller.is_a?(Organization)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => @seller.id).order("order_items.name")
    end
  end

  def self.find(seller, id)
    order = Order.orders_for_seller(seller).find(id)
    new(order, seller)
  end

  def credit_amount_visible_to_current_seller
    if credit.paying_org == nil
      (@order.credit_amount / (@order.sellers.count || 1)).round 2
    elsif credit.paying_org == @seller || (@seller.is_a?(User) && @seller.member_of_organization?(credit.paying_org))
      # When a user belongs to more than one organization that are on the order,
      # the display will be confusing because they won't know which organization
      # is paying the credit.
      @order.credit_amount
    else
      0
    end
  end

  def credit_amount
    if credit_paid_by_sellers?
      credit_amount_visible_to_current_seller
    else
      0
    end
  end

  def total_cost
    gross_total - discount - credit_amount
  end

  def items_attributes=(_)
  end

  def delivery_fees
    0
  end

  def seller_id
    @seller.id
  end

  private

  def credit_paid_by_sellers?
    @order.credit_amount > 0 && credit.payer_type == Credit::ORGANIZATION
  end

  def share_of_credit
  end
end
