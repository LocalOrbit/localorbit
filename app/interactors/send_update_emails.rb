class SendUpdateEmails
  include Interactor

  def perform
    return if Rails.env.production?

    if users_should_be_updated?
      OrderMailer.delay.buyer_order_updated(order)
    end

    order.sellers_with_changes.each do |seller|
      unless seller.users.empty?
        OrderMailer.delay.seller_order_updated(order, seller)
      end
    end

    unless order.market.managers.empty?
      OrderMailer.delay.market_manager_order_updated(order)
    end
  end

  def users_should_be_updated?
    uuid = order.audits.last.try(:request_uuid)

    if uuid.present?
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").
        select {|audit| audit.audited_changes["quantity"].present? }.any? &&
        order.organization.users.any?
    else
      false
    end
  end
end
