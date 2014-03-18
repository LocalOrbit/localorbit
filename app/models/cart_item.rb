class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true

  def unit_price
    price = product.prices.where('min_quantity < ?', quantity).where(organization_id: cart.organization.id).order(:min_quantity).last || product.prices.where('min_quantity < ?', quantity).where(organization_id: nil).order(:min_quantity).last

    price.decorate
  end

  def total_price
    "$%.2f" % (unit_price.sale_price * quantity)
  end
end
