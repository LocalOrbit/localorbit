class CartItem < ActiveRecord::Base
  belongs_to :cart, inverse_of: :items
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true
  validates :quantity, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647, only_integer: true}

  validate :validate_minimum_quantity, unless: "errors.has_key? :quantity"
  validate :quantity_is_available, unless: "errors.has_key? :quantity"

  def prices
    product.prices_for_market_and_organization(cart.market, cart.organization)
  end

  def unit_price
    if quantity.nil? || quantity <= 0
      prices.first
    else
      prices.select {|p| p.min_quantity <= quantity }.last
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
    super(methods: [:total_price, :unit_sale_price, :valid?, :destroyed?])
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
    if product && product.available_inventory < quantity
      errors.add(:quantity, "available for purchase: #{product.available_inventory}")
    end
  end
end
