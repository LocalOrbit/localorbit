class OrderTemplate < ActiveRecord::Base
  has_many :items, class_name: :OrderTemplateItem, inverse_of: :order_template
  belongs_to :market

  validates :market, :name, presence: true
  validates :name, uniqueness: {scope: [:market, :buyer_id]}

  def self.create_from_cart!(cart, name, user)
    if user.buyer_only?
      template = OrderTemplate.create!(name: name, market: cart.market, buyer_id: cart.organization.id)
    else
      template = OrderTemplate.create!(name: name, market: cart.market, buyer_id: nil)
    end
    cart.items.each do |item|
      OrderTemplateItem.create!(product: item.product, quantity: item.quantity, order_template: template)
    end
    template
  end
end
