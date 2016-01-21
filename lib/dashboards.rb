module Dashboards

  def upcoming_deliveries(user_type)
    if user_type == "B" || user_type == "M"
      @deliveries = Order.orders_for_buyer(current_user).upcoming_buyer_delivery.joins(:items).where(order_items: {delivery_status: "pending"}, market: current_market).select('orders.id AS order_id','deliveries.*').
          sort_by {|d| d.buyer_deliver_on }
      use_date = :buyer_deliver_on

      pending_amount = Order.orders_for_buyer(current_user).where(:delivery => @deliveries.map(&:id), market: current_market).sum(:total_cost)
    else
      @deliveries = Order.orders_for_seller(current_user).upcoming_delivery.where(order_items: {delivery_status: "pending"}, market: current_market).select('orders.id AS order_id','deliveries.*').
          sort_by {|d| d.deliver_on }
      use_date = :deliver_on

      pending_orders = Order.orders_for_seller(current_user).where(:delivery => @deliveries.map(&:id), market: current_market)

      pending_amount = sum_money_to_sellers(pending_orders, current_user)
    end

    if @deliveries.length > 0
      first_delivery = @deliveries.first.send(use_date)
    else
      first_delivery = Date.today
    end

    last_delivery = first_delivery + 20.days
    delivery_for_day = @deliveries.each_with_object({}) { |d,map| map[d.send(use_date).yday] ||= d }

    now = DateTime.now
    calendar_start = now - now.wday
    calendar_end = last_delivery + (6 - last_delivery.wday)

    delivery_weeks = [ [] ]

    (calendar_start..calendar_end).each { |day|
      delivery_id = nil
      css_class = if delivery_for_day[day.yday]
                    delivery_id = delivery_for_day[day.yday].id
                    order_id = delivery_for_day[day.yday].order_id
                    "cal-date"
                  else
                    "cal-date disabled"
                  end
      if delivery_weeks[-1].length == 7
        delivery_weeks.push [ ]
      end
      delivery_weeks[-1].push({ day: day, css_class: css_class, delivery_id: delivery_id, order_id: order_id })
    }

    {:numPendingDeliveries => @deliveries.length, :deliveries => delivery_weeks, :pendingDeliveryAmount => pending_amount ? number_to_currency(pending_amount, precision: 0) : '$0'}
  end

  def group_to_sellers(orders, group_by)
    total = Array.new
    count = Array.new
    orders.inject(0) do |t, order|
      grp = order.created_at.send(group_by)

      if total[grp].nil?
        total[grp] = BigDecimal(0)
      end

      if count[grp].nil?
        count[grp] = BigDecimal(0)
      end

      total[grp] = total[grp] + order.items.map(&:seller_net_total).reduce(:+)
      count[grp] = count[grp] + 1
    end
    {:count => count.to_a, :total => total.to_a}
  end

  def group_to_buyers(orders, group_by)
    total = Array.new
    count = Array.new
    prev_grp = orders.length > 0 ? orders[0].created_at.send(group_by) - 1 : 0

    orders.inject(0) do |t, order|
      grp = order.created_at.send(group_by)

      if total[grp].nil?
        total[grp] = BigDecimal(0)
      end

      if count[grp].nil?
        count[grp] = BigDecimal(0)
      end

      #if prev_grp + 1 != grp
      # grp = prev_grp + 1
      #  total[grp+1] = 0
      #else
        total[grp] = total[grp] + order.total_cost
        count[grp] = count[grp] + 1
      #end
      prev_grp = grp

    end
    {:count => count.to_a, :total => total.to_a}
  end

  #def sum_money_to_sellers(items)
  #    items.map(&:seller_net_total).reduce(:+)
  #end

  def sum_money_to_sellers(orders, current_user)
    orders.inject(0) do |total, order|
      total + order.items.for_user(current_user).map(&:seller_net_total).reduce(:+)
    end
  end

  def sum_order_total(orders)
    orders.map(&:total_cost).reduce(:+) || 0
  end

end
