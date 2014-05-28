module OrderPresenter
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

  def buyer_payment_status
    @order.payment_status
  end

  def discount
    totals[:discount]
  end

  def gross_total
    totals[:gross]
  end

  def net_total
    totals[:net]
  end

  def payment_fees
    totals[:payment]
  end

  def transaction_fees
    totals[:transaction]
  end

  def market_fees
    totals[:market]
  end

  def totals
    @totals ||= items.inject(discount: 0, gross: 0, net: 0, payment: 0, transaction: 0, market: 0) do |totals, item|
      next totals if item.delivery_status == "canceled"

      totals[:discount]    += item.discount
      totals[:gross]       += item.gross_total
      totals[:transaction] += item.local_orbit_seller_fee
      totals[:net]         += item.seller_net_total
      totals[:payment]     += item.payment_seller_fee
      totals[:market]      += item.market_seller_fee
      totals
    end
  end

  def errors
    @order.errors
  end

  def items_attributes=(values)
  end
end
