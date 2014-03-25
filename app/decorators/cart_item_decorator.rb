class CartItemDecorator < Draper::Decorator
  include ActiveSupport::NumberHelper
  delegate_all

  def display_total_price
    number_to_currency total_price
  end
end
