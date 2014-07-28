class ApplyDiscountToOrderItems
  include Interactor

  def perform
    if order.discount
      order.items.each do |item|
        item.discount = (cart.discount_amount * (item.gross_total / order.subtotal)).round(2)
      end

      if (curr_discount = order.items.each.sum(&:discount)) > cart.discount_amount
        items = order.items.
          sort {|a,b| b.discount <=> a.discount }[0, (curr_discount - cart.discount_amount) * 100]
        items.each {|i| i.decrement(:discount, BigDecimal.new('0.01')) }
      end

      if (curr_discount = order.items.each.sum(&:discount)) < cart.discount_amount
        items = order.items.
          sort {|a,b| b.discount <=> a.discount }[0, (curr_discount - cart.discount_amount) * 100]
        items.each {|i| i.increment(:discount, BigDecimal.new('0.01')) }
      end
    end
  end
end
