class OrderTemplate < ActiveRecord::Base
  has_many :items, class_name: :OrderTemplateItem, inverse_of: :order_template
  belongs_to :market

  validates :market, :name, presence: true
  validates :name, uniqueness: {scope: :market}

  def self.create_from_cart!(cart, name)
    template = OrderTemplate.create!(name: name, market: cart.market)
    cart.items.each do |item|
      OrderTemplateItem.create!(product: item.product, quantity: item.quantity, order_template: template)
    end
    template
  end
end
