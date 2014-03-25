class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true

  def prices
    product.prices.for_market_and_org(cart.market, cart.organization)
  end

  def unit_price
    if quantity.nil? || quantity == 0
      prices.order('min_quantity ASC').first.decorate
    else
      prices.where('min_quantity <= ?', quantity).order('sale_price ASC').first.decorate
    end
  end

  def total_price
    unit_price.sale_price * quantity
  end

  def unit_sale_price
    unit_price.sale_price
  end

  def as_json(opts=nil)
    super(methods: [:total_price, :unit_sale_price])
  end
end
