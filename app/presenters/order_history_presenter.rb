class OrderHistoryPresenter
  def initialize(order_id)
    @order = Order.find(order_id)
  end

  def each_activity
    activities.each do |activity|
      activity_presenter = OrderHistoryActivityPresenter.new(activity)
      yield activity_presenter if activity_presenter.actions.any?
    end
  end

  private

  # Groups of audits
  def activities
    audits = Audit.where("(associated_type = 'Order' AND associated_id = :order_id) OR
    (auditable_type = 'Order' AND auditable_id = :order_id) OR
    (auditable_type = 'Payment' AND auditable_id IN (:payment_ids))",
      order_id: @order.id,
      payment_ids: @order.payment_ids
    ).where("user_id IS NOT NULL").reorder(:request_uuid, :created_at)

    # return the first audit so we can grab timestamp and user
    audits.group_by(&:request_uuid).
    sort_by {|_, list| list.first.created_at }.reverse.map {|_, list| list }
  end
end
