class CartItem < ActiveRecord::Base
  include ActiveSupport::NumberHelper
  cattr_accessor :order
  attr_accessor :check_qty

  audited allow_mass_assignment: true, associated_with: :cart
  belongs_to :cart, inverse_of: :items
  belongs_to :product
  belongs_to :lot

  validates :cart, presence: true
  validates :product, presence: true
  validates :quantity, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647, only_integer: true}

  validate :validate_minimum_quantity, unless: "errors.has_key? :quantity"
  validate :quantity_is_available, unless: "errors.has_key? :quantity"

  def unit_price
    if sale_price > 0
      nil
    else
      Orders::UnitPriceLogic.unit_price(product, cart.market, cart.organization, !order.nil? && order.market.add_item_pricing ? order.created_at : Time.current, quantity)
    end
  end

  def total_price
    if quantity && quantity > 0
      if unit_price.nil?
        sale_price * quantity
      else
        unit_price.sale_price * quantity
      end
    else
      0.0
    end
  end

  def formatted_total_price
    number_to_currency total_price
  end

  def unit_sale_price
    if sale_price > 0
      sale_price
    elsif unit_price
      unit_price.sale_price
    else
      0.0
    end
  end

  def as_json(_opts=nil)
    super(methods: [:total_price, :unit_sale_price, :net_price, :valid?, :destroyed?, :formatted_total_price])
  end

  def unit
    if quantity == 1
      product.unit_singular
    else
      product.unit_plural
    end
  end

  protected

  def validate_minimum_quantity
    if product && quantity
      min_purchase_quantity = product.minimum_quantity_for_purchase(organization: cart.organization, market: cart.market)
      if min_purchase_quantity > quantity
        errors.add(:quantity, ": You must order at least #{min_purchase_quantity}")
      end
    end
  end

  def quantity_is_available
    if check_qty && product && product.available_inventory(Time.current.end_of_minute, cart.market.id, cart.organization.id) < quantity
      errors.add(:quantity, "available for purchase: #{product.available_inventory(Time.current.end_of_minute, cart.market.id, cart.organization.id)}")
    end
  end
end
