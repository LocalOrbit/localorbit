module Dashboards

  def upcoming_deliveries
    @deliveries = current_market.deliveries.upcoming_for_seller(current_user).
        sort_by {|d| d.deliver_on }

    if @deliveries.length > 0
      first_delivery = @deliveries.first.deliver_on
    else
      first_delivery = Date.today
    end

    last_delivery = first_delivery + 20.days
    delivery_for_day = @deliveries.each_with_object({}) { |d,map| map[d.deliver_on.yday] ||= d }

    now = DateTime.now
    calendar_start = now - now.wday
    calendar_end = last_delivery + (6 - last_delivery.wday)

    delivery_weeks = [ [] ]

    (calendar_start..calendar_end).each { |day|
      delivery_id = nil
      css_class = if day < first_delivery || last_delivery < day
                    "cal-date disabled"
                  elsif delivery_for_day[day.yday]
                    delivery_id = delivery_for_day[day.yday].id
                    "cal-date"
                  else
                    "cal-date disabled"
                  end
      if delivery_weeks[-1].length == 7
        delivery_weeks.push [ ]
      end
      delivery_weeks[-1].push({ day: day, css_class: css_class, delivery_id: delivery_id })
    }
    {:numPendingDeliveries => @deliveries.length, :deliveries => delivery_weeks}
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

  def sum_money_to_sellers(orders)
    orders.inject(0) do |total, order|
      total + order.items.map(&:seller_net_total).reduce(:+)
    end
  end

  def sum_order_total(orders)
    orders.map(&:total_cost).reduce(:+) || 0
  end

end
