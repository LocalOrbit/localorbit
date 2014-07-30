class DiscountDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper

  delegate_all

  def market_name
    market_id.nil? ? "All Markets" : market.name
  end

  def short_type_indicator
    fixed? ? "$" : "%"
  end

  def discounted_amount
    fixed? ? number_to_currency(discount.discount) : "#{discount.discount}%"
  end

  def available_uses
    maximum_uses == 0 ? "Unlimited" : maximum_uses - total_uses
  end
end
