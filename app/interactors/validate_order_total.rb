class ValidateOrderTotal
  include Interactor

  def perform
    order = context[:order]
    credit_amt = order.credit.nil? ? 0 : order.credit_amount
    total = 0
    context[:order_params]["items_attributes"].each do |p|
      if p[1]["_destroy"] && p[1]["_destroy"].empty?
        if is_number?(p[1]["quantity"]) && BigDecimal(p[1]["quantity"]) >= 0
          qty = BigDecimal(p[1]["quantity"])
          item = OrderItem.where(id: p[1]["id"])
          total += item[0].unit_price * qty
        else
          context[:status] = "failed_qty"
        end
      end
    end
    if context[:status].nil? && total > 0 && total - credit_amt < 0
      context[:status] = "failed_negative"
    end
    context.fail! unless context[:status].nil?
  end

  def is_number?(string)
    true if Float(string) rescue false
  end
end