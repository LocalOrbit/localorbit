class SendUpdateEmails
  include Interactor

  def perform
    require_in_context :order


    send_update_to_suppliers order.sellers_with_changes
    send_update_to_suppliers order.sellers_with_cancel
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

  def send_update_to_suppliers(suppliers)
    suppliers.
      find_all {|supplier| supplier.users.present?}.
      each do |supplier|
        OrderMailer.
          delay(priority: 10).
          seller_order_updated(order, supplier)
      end
  end
end
