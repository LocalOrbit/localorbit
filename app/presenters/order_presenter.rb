module OrderPresenter
  include TotalsPresenter

  def self.included(base)
    base.class_eval do
      attr_reader :items
      delegate :id, :delivery, :billing_organization_name, :billing_address, :billing_city,
               :billing_state, :billing_zip, :billing_phone, :delivery_address, :delivery_city,
               :delivery_state, :delivery_zip, :delivery_fees,
               :invoice_due_date, :invoiced_at, :invoiced?, :market, :notes, :order_number,
               :organization, :payment_method, :payment_note, :payment_status, :placed_at,
               to: :@order
    end
  end

  def grouped_items
    @items.group_by do |item|
      item.seller_name
    end
  end

  def display_delivery_fees?(user)
    user.admin? || user.market_manager? || user.buyer_only?
  end

  def buyer_payment_status
    @order.payment_status
  end

  def errors
    @order.errors
  end

  def items_attributes=(_)
  end

  def activities
    audits = Audit.where("(associated_type = 'Order' AND associated_id = :order_id) OR
    (auditable_type = 'Order' AND auditable_id = :order_id) OR
    (auditable_type = 'Payment' AND auditable_id IN (:payment_ids))",
                order_id: @order.id,
                payment_ids: @order.payment_ids
    ).where("user_id IS NOT NULL").reorder(:request_uuid, :created_at).decorate

    # return the first audit so we can grab timestamp and user
    audits.group_by(&:request_uuid).map { |uuid, audits| [audits.first, audits] }
  end

  def refund?
    ["ach", "credit card"].include?(@order.payment_method) && refund_for_changes && refund_for_changes > 0
  end

  def refund_for_changes
    @refund_for_changes ||= begin
      if @order.audits.present?
        total_cost_update = @order.audits.last.audited_changes["total_cost"]

        if total_cost_update.present?
          total_cost_update[0] - total_cost_update[1]
        end
      end
    end
  end
end
