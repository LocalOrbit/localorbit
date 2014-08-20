class OrderItemDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper

  delegate_all

  def quantity_with_unit
    "#{object.quantity} #{unit}"
  end

  def previous_quantity_with_unit
    previous_quantity = previous_value_for("quantity")
    "#{previous_quantity} #{unit}" if previous_quantity
  end

  def price_per_unit
    "#{number_to_currency(object.unit_price)}/#{unit}"
  end

  def placed_at
    order.placed_at.strftime("%m/%d/%Y")
  end

  def order_number
    order.order_number
  end

  def category_name
    product.category.name.to_s.titleize
  end

  def product_name
    name.to_s
  end

  def seller_name
    product.organization.name.to_s
  end

  def buyer_name
    order.organization.name.to_s
  end

  def market_name
    order.market.name.to_s
  end

  def unit_price
    number_to_currency(object.unit_price)
  end

  def discount
    number_to_currency(object.discount)
  end

  def quantity
    number_with_delimiter(delivered? ? object.quantity_delivered : object.quantity)
  end

  def row_total
    number_to_currency(object.gross_total)
  end

  def net_sale
    number_to_currency(object.seller_net_total)
  end

  def payment_method
    order.payment_method.to_s.titleize
  end

  def delivery_status
    object.delivery_status.to_s.titleize
  end

  def buyer_payment_status
    payment_status.to_s.titleize
  end

  def seller_payment_status
    object.seller_payment_status.to_s.titleize
  end

  def canceled?
    object.delivery_status == "canceled"
  end

  private

  def previous_value_for(column)
    changes = latest_changes
    changes.present? && changes[column].present? && changes[column].kind_of?(Array) ? changes[column].first : false
  end

  def latest_changes
    @latest_changes ||= begin
      if object.audits.present?
        uuid = object.order.audits.last.request_uuid
        changes = object.audits.where(request_uuid: uuid).map(&:audited_changes)
        changes.inject({}) {|result, audit| result.merge(audit) }
      else
        {}
      end
    end
  end
end
