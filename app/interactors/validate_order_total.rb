class ValidateOrderTotal
  include Interactor

  def perform
    context[:failed] = false
    order = context[:order]
    credit_amt = order.credit.nil? ? 0 : order.credit.amount
    total = 0
    context[:order_params]["items_attributes"].each do |p|
      if p[1]["_destroy"] && p[1]["_destroy"].empty?
        qty = BigDecimal(p[1]["quantity"])
        item = OrderItem.where(id: p[1]["id"])
        total += item[0].unit_price * qty
      end
    end
    context[:status] = "failed_total" unless total - credit_amt >= 0
    context[:failed] = true unless total - credit_amt >= 0
  end
end