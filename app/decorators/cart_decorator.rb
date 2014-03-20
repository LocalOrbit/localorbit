class CartDecorator < Draper::Decorator
  delegate_all

  def display_subtotal
    "$%.2f" % subtotal
  end
end
