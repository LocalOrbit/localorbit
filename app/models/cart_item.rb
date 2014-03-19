class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true

  def prices
    product.prices.for_market_and_org(cart.market, cart.organization)
  end

  def unit_price
    # NOTE: Use underscore.js to filter the client-side prices list
    # to do the min_quantity check
    prices.where('min_quantity <= ?', quantity).order('sale_price ASC').first.decorate
  end

  def total_price
    "$%.2f" % (unit_price.sale_price * quantity)
  end
end
