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
    Audit.where("(associated_type = 'Order' AND associated_id = :order_id) OR
    (auditable_type = 'Order' AND auditable_id = :order_id) OR
    (auditable_type = 'Payment' AND auditable_id IN (:payment_ids))",
      order_id: @order.id,
      payment_ids: @order.payment_ids
    ).reorder("created_at DESC")
  end
end
