module DeliveryStatus
  def delivery_status
    statuses = items.map(&:delivery_status).uniq.map(&:downcase)

    # TODO: Currently, canceled will only return if all items are canceled, this logic needs to be confirmed
    return statuses.first if statuses.size == 1
    return "contested" if statuses_within(statuses, ["contested", "pending"])
    return "partially delivered" if statuses_within(statuses, ["delivered", "pending"])
    return "contested, partially delivered" if statuses_within(statuses, ["pending", "delivered", "contested"])
  end

  private

  def statuses_within(statuses, query)
    (statuses | query).sort == query.sort
  end
end