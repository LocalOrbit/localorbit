class Cart < ActiveRecord::Base
  belongs_to :market
  belongs_to :organization
  belongs_to :delivery
  belongs_to :location

  validates :organization, presence:true
  validates :market, presence:true
  validates :delivery, presence:true

  has_many :items, class_name: :CartItem do
    def for_checkout
      includes(product: :organization).joins(product: :organization).order("organizations.name, products.name").group_by do |item|
        item.product.organization.name
      end
    end
  end

  def subtotal
    items.inject(0){ |sum, item| sum += item.total_price }
  end
end
