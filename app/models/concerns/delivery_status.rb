module DeliveryStatus
  extend ActiveSupport::Concern

  def delivery_status_for_user(user)
    order_items = items_for_seller(user)
    aggrigate_delivery_status_for_items(order_items)
  end

  def delivered?
    aggrigate_delivery_status_for_items(items) == "delivered"
  end

  def undelivered_for_user?(user)
    delivery_status_for_user(user) == "pending"
  end

  def cache_delivery_status
    self.delivery_status = aggrigate_delivery_status_for_items(items)
  end

  private

  def statuses_within(statuses, query)
    (query & statuses) == query
  end

  def items_for_seller(user)
    organization_ids = user.managed_organizations.map(&:id)
    if user.admin? || user.market_manager? || organization_ids.include?(organization_id)
      items
    else
      items.joins(:product).where(products: {organization_id: organization_ids})
    end
  end

  def aggrigate_delivery_status_for_items(items)
    statuses = (items.try(:loaded?) ? items.map(&:delivery_status) : items.pluck(:delivery_status)).map(&:downcase).uniq

    Orders::DeliveryStatusLogic.overall_status(statuses)
    # TODO: Currently, canceled will only return if all items are canceled, this logic needs to be confirmed
    # if statuses.size > 1 && statuses.include?("canceled")
    #   statuses.delete("canceled")
    # end
    #
    # if statuses.size == 1
    #   statuses.first
    # elsif statuses_within(statuses, %w(pending delivered contested))
    #   "contested, partially delivered"
    # elsif statuses.include?("contested")
    #   "contested"
    # elsif statuses_within(statuses, %w(delivered pending))
    #   "partially delivered"
    # else
    #   "canceled"
    # end
  end
end
