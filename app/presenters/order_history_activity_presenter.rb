class OrderHistoryActivityPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :activities

  def initialize(activities)
    @activities = activities
  end

  def who
    output = ""
    if metadata.masquerader
      output += User.find(metadata.masquerader.id).email
      output += "<br>impersonating<br>"
    end
    output += metadata.user_name_or_email
    output.html_safe
  end

  def when
    metadata.display_date
  end

  def actions
    return @list if defined?(@list)

    @list = []
    if activities.any? {|a| a.auditable_type == "Order" && a.action == "create" }
      @list << "Order Placed"
      @list << process(activities.reject {|a| %w(Order OrderItem).include?(a.auditable_type) })
    else
      @list << process(activities)
    end

    @list = @list.flatten.compact
  end

  private

  def process(list)
    list.map do |item|
      case item.auditable_type
        when "Order"
          process_order(item)
        when "OrderItem"
          process_order_item(item)
        when "Payment"
          process_payment(item)
        when "Credit"
          process_credit(item)
        else
          nil
      end
    end
  end

  def process_order(item)
    data = []
    payment_status = last_value_for_change(item, "payment_status")
    if payment_status && payment_status != "pending"
      data << "Buyer Payment Status: #{payment_status.humanize.capitalize}"
    end

    if last_value_for_change(item, "invoiced_at").present?
      data << "Order Invoiced"
    end

    delivery_status = last_value_for_change(item, "delivery_status")
    if delivery_status.present? && !delivery_status.include?("pending")
      data << "Order #{delivery_status.humanize.capitalize}"
    end

    delivery_fees = last_value_for_change(item, "delivery_fees")
    if delivery_fees == 0
      data << "Delivery Fee Removed"
    end

    data
  end

  def process_order_item(item)
    item_name = if item.auditable
      "#{item.auditable.name}, #{item.auditable.unit} from #{item.auditable.seller_name}"
    else
      "#{last_value_for_change(item, "name")}, #{last_value_for_change(item, "unit")} from #{last_value_for_change(item, "seller_name")}"
    end

    if item.action == "destroy"
      "Item Cancelled: #{item_name}"
    elsif item.action == "create"
      "Item Added: #{item_name}"
    elsif item.audited_changes["quantity"].present?
      "Item Quantity Updated: #{item_name} (#{last_value_for_change(item, "quantity")})"
    elsif item.audited_changes["unit_price"].present?
      "Item Unit Price Updated: #{item_name} (#{last_value_for_change(item, "unit price")}"
    end
  end

  def process_payment(item)
    payment_type = last_value_for_change(item, "payment_type")
    payment_method = last_value_for_change(item, "payment_method")
    payee_name = item.auditable.payee.try(:name)

    if payment_type == "seller payment"
      "Seller Payment Status: #{last_value_for_change(item, "status")} (#{payee_name})"
    elsif payment_type == "order refund"
      "Refunded #{payment_method.humanize.capitalize} #{number_to_currency(item.auditable.amount)}"
    end
  end

  def process_credit(item)
    amount = last_value_for_change(item, "amount")
    amount_type = last_value_for_change(item, "amount_type")
    deleted = last_value_for_change(item, "deleted_at")
    if item.action == "update" && deleted.present?
    "Credit Removed"
    else
      if amount
        if amount_type == "fixed"
          amount = number_to_currency(amount)
        else
          amount = number_to_percentage(amount, precision: 2)
        end
        if item.action == "create"
          "Credit Added: #{amount}"
        elsif item.action == "update"
          "Credit Changed: #{amount}"
        end
      end
    end
  end

  def last_value_for_change(item, key)
    Array(item.audited_changes[key]).last
  end

  def metadata
    activities.first.decorate
  end
end
