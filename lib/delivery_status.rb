module DeliveryStatus
  def delivery_status
    statuses = items.pluck(:delivery_status).uniq.map(&:downcase)

    # TODO: Currently, canceled will only return if all items are canceled, this logic needs to be confirmed
    return statuses.first if statuses.size == 1
    return "contested, partially delivered" if statuses_within(statuses, ["pending", "delivered", "contested"])
    return "contested" if statuses.include?("contested")
    return "partially delivered" if statuses_within(statuses, ["delivered", "pending"])
  end

  private

  def statuses_within(statuses, query)
    (query & statuses) == query
  end
end