class CartItemDecorator < Draper::Decorator
  delegate_all

  def display_total_price
    "$%.2f" % total_price
  end
end
