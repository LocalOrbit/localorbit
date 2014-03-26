class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  validate :quantity_is_available, unless: "errors.has_key? :quantity"

  def prices
    product.prices.for_market_and_org(cart.market, cart.organization)
  end

  def unit_price
    if quantity.nil? || quantity <= 0
      prices.order('min_quantity ASC').first.decorate
    else
      prices.where('min_quantity <= ?', quantity).order('sale_price ASC').first.decorate
    end
  end

  def total_price
    return 0.0 unless quantity && quantity > 0
    unit_price.sale_price * quantity
  end

  def unit_sale_price
    unit_price.sale_price
  end

  def as_json(opts=nil)
    super(methods: [:total_price, :unit_sale_price, :valid?])
  end

  protected

  def quantity_is_available
    if product && product.available_inventory < quantity
      errors.add(:quantity, "available for purchase: #{product.available_inventory}")
    end
  end

end
