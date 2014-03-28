class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  validate :validate_minimum_quantity
  validate :quantity_is_available, unless: "errors.has_key? :quantity"

  def prices
    product.prices.for_market_and_org(cart.market, cart.organization)
  end

  def unit_price
    if quantity.nil? || quantity <= 0
      prices.order('min_quantity ASC').first
    else
      prices.where('min_quantity <= ?', quantity).order('sale_price ASC').first
    end
  end

  def total_price
    return 0.0 unless quantity && quantity > 0 && unit_price
    unit_price.sale_price * quantity
  end

  def unit_sale_price
    return 0.0 unless unit_price
    unit_price.sale_price
  end

  def as_json(opts=nil)
    super(methods: [:total_price, :unit_sale_price, :valid?])
  end

  def unit
    if quantity == 1
      product.unit.singular
    else
      product.unit.plural
    end
  end

  protected

  def validate_minimum_quantity
    if product && quantity
      min_purchase_quantity = product.minimum_quantity_for_purchase(organization:cart.organization, market:cart.market)
      if min_purchase_quantity > quantity
        errors.add(:quantity, ": You must order at least #{min_purchase_quantity}")
      end
    end
  end

  def quantity_is_available
    if product && product.available_inventory < quantity
      errors.add(:quantity, "available for purchase: #{product.available_inventory}")
    end
  end

end
