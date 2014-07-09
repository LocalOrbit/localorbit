module DeliveryStatus
  def delivery_status
    statuses = (items.try(:loaded?) ? items.map(&:delivery_status) : items.pluck(:delivery_status)).map(&:downcase).uniq

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

  private

  def statuses_within(statuses, query)
    (query & statuses) == query
  end
end
