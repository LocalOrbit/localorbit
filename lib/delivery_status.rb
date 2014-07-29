module DeliveryStatus
  def delivery_status_for_user(user)
    order_items = items_for_seller(user)
    statuses = (order_items.try(:loaded?) ? order_items.map(&:delivery_status) : order_items.pluck(:delivery_status)).map(&:downcase).uniq

    # TODO: Currently, canceled will only return if all items are canceled, this logic needs to be confirmed
    if statuses.size > 1 && statuses.include?("canceled")
      statuses.delete("canceled")
    end

    if statuses.size == 1
      statuses.first
    elsif statuses_within(statuses, %w(pending delivered contested))
      "contested, partially delivered"
    elsif statuses.include?("contested")
      "contested"
    elsif statuses_within(statuses, %w(delivered pending))
      "partially delivered"
    else
      "canceled"
    end
  end

  def delivered?
    delivery_status == "delivered"
  end

  def undelivered_for_user?(user)
    delivery_status_for_user(user) == "pending"
  end

  private

  def statuses_within(statuses, query)
    (query & statuses) == query
  end

  def items_for_seller(user)
    if user.admin? || user.market_manager?
      items
    else
      organization_ids = user.managed_organizations.pluck(:id)
      items.joins(:product).where(products: { organization_id: organization_ids})
    end
  end
end
