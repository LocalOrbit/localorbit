class ApplyDiscountToOrderItems
  include Interactor

  def perform
    return unless order.discount

    order.items.each do |item|
      item.discount = (cart.discount_amount * item.gross_total / order.subtotal).round(2)
    end

    while (curr_discount = order.items.each.sum(&:discount)) != cart.discount_amount
      limit = (curr_discount - cart.discount_amount).abs * 100
      items = order.items.sort {|a,b| b.discount <=> a.discount }[0, limit.to_i]
      if curr_discount > cart.discount_amount
        items.each {|i| i.decrement(:discount, BigDecimal.new('0.01')) }
      else
        items.each {|i| i.increment(:discount, BigDecimal.new('0.01')) }
      end
    end
  end
end
