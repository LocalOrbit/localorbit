class OrderItemDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper

  delegate_all

  def quantity_with_unit
    "#{Format.quantity(object.quantity)} #{unit}"
  end

  def previous_quantity_with_unit
    previous_quantity = previous_value_for("quantity")
    "#{Format.quantity(previous_quantity)} #{unit}" if previous_quantity
  end

  def price_per_unit
    "#{number_to_currency(object.unit_price)}/#{unit}"
  end

  def placed_at
    order.placed_at.strftime("%m/%d/%Y")
  end

  def delivered_at
    if !object.delivered_at.nil?
      object.delivered_at.strftime("%m/%d/%Y")
    else
      nil
    end
  end

  def order_number
    order.order_number
  end

  def category_name
    if !product.top_level_category_id.nil?
      #product.category.name.to_s.titleize
      Category.find(product.top_level_category_id).name.to_s.titleize
    end
  end

  def subcategory_name
    if !product.second_level_category.nil?
      product.second_level_category.name.to_s.titleize
    end
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

  def discount_code
    order.discount.try(:code).try(:to_s)
  end

  def discount
    number_to_currency(object.discount)
  end

  def discount_amount
    number_to_currency(order.discount.try(:discount).try(:to_s))
  end

  def quantity
    value = delivered? ? object.quantity_delivered : object.quantity
    Format.quantity(value)
  end

  def row_total
    number_to_currency(object.gross_total)
  end

  def net_sale
    number_to_currency(object.seller_net_total)
  end

  def fee_pct
    if !object.category_fee_pct.nil?
      number_to_percentage(object.category_fee_pct)
    elsif object.product_fee_pct > 0
      number_to_percentage(object.product_fee_pct)
    else
      number_to_percentage(order.market.market_seller_fee)
    end
  end

  def profit
    number_to_currency(object.gross_total - object.seller_net_total)
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

  def product_code
    object.product.code
  end

  def canceled?
    object.delivery_status == "canceled"
  end

  def fulfillment_day
    schedule = object.order.delivery.delivery_schedule

    if buyer_day = schedule.try(:buyer_day)
      DeliverySchedule::WEEKDAY_ABBREVIATIONS[buyer_day]
    else
      ""
    end
  end

  def fulfillment_type
    if schedule = object.order.delivery.delivery_schedule
      schedule.decorate.fulfillment_type
    else
      ""
    end
  end

  def lot_info
    s = ""
    object.lots.each do |lot|
      lt = Lot.find(lot.lot_id)
      if not lt.expires_at.nil?
        s = s + "#{lt.number.to_s} | Exp #{lt.expires_at.to_date.to_s} | #{lt.quantity.to_s} avail. | Good from #{lt.good_from.to_date.to_s}"
      else
        s = 'N/A'
      end
    end
    s
  end

  private

  def previous_value_for(column)
    changes = latest_changes
    changes.present? && changes[column].present? && changes[column].is_a?(Array) ? changes[column].first : false
  end

  def latest_changes
    @latest_changes ||= begin
      uuid = object.order.audits.last.try(:request_uuid)

      if uuid && object.audits.present?
        changes = object.audits.where(request_uuid: uuid).map(&:audited_changes)
        changes.inject({}) {|result, audit| result.merge(audit) }
      else
        {}
      end
    end
  end
end
