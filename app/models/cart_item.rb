class CartItem < ActiveRecord::Base
  after_initialize :default_values

  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true

  private
  def default_values
    self.quantity = 0
  end

end
