class SendUpdateEmails
  include Interactor

  def perform
    send_update_to_sellers order.sellers_with_changes
    send_update_to_sellers order.sellers_with_cancel
  end

  def users_should_be_updated?
    uuid = order.audits.last.try(:request_uuid)

    if uuid.present?
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").
        select {|audit| audit.audited_changes["quantity"].present?}.any? &&
        order.organization.users.any?
    else
      false
    end
  end

  def users_should_be_updated_on_remove?
    uuid = order.audits.last.try(:request_uuid)

    if uuid.present?
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").
          select {|audit| !audit.audited_changes["quantity"].present? || audit.audited_changes["quantity"][1] == 0 || audit.action == :destroy
      }.any? &&
          order.organization.users.any?
    else
      false
    end
  end

  private

  def send_update_to_sellers(sellers)
    sellers.each do |seller|
      if seller.users.present?
        OrderMailer.
          delay(priority: 10).
          seller_order_updated(order, seller)
      else
        ap "Warning: trying to send update email to seller with no users."
      end
    end
  end
end
