class SellerOverview
  def initialize(opts={})
    @seller = opts[:seller]
    @time = Time.current

    @electronic_payment_orders = seller.orders.where(payment_method: ["purchase order", "ach"])
    @po_payment_orders = seller.orders.where(payment_method: "credit_card")
  end

  def overdue
    orders = @po_payment_orders.where()
  end
end
