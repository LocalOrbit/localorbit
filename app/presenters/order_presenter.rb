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

  def display_delivery_fees?(user, market)
    user.admin? || user.can_manage_market?(market) || user.buyer_only?(market)
  end

  def buyer_payment_status
    @order.payment_status
  end

  def errors
    @order.errors
  end

  def items_attributes=(_)
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
