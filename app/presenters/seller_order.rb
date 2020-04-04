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
    :signature_data,
    to: :@order

  attr_reader :seller

  def initialize(order, seller, current_fee=0)
    @order = order.decorate
    @seller = seller
    @current_fee = current_fee
    @add
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
      if credit.amount_type == "fixed"
        (@order.credit_amount / (@order.sellers.count || 1)).round 2
      else
        (gross_total / @order.gross_total * @order.credit_amount).round 2 #/
      end
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
    if credit_amount > 0
      gross_total - discount - credit_amount + @current_fee
    else
      gross_total - discount + @current_fee
    end
  end

  def items_attributes=(_)
  end

  def delivery_fees
    @current_fee
  end

  def seller_id
    @seller.id
  end

  private

  def credit_paid_by_sellers?
    @order.credit_amount > 0 && credit.payer_type == Credit::ORGANIZATION
  end
end
