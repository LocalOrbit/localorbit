module OrderPresenter
  def self.included(base)
    base.class_eval do
      attr_reader :items
      delegate :delivery_fees, :delivery_status, :order_number, :organization, :payment_method, :payment_note, :placed_at, :market, to: :@order
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

  def seller_payment_status
    # TODO: Make work after Payments exists
    'Unpaid'
  end

  def transaction_fees
    totals[:transaction]
  end

  def totals
    @totals ||= items.inject({discount: 0, gross: 0, net: 0, payment: 0, transaction: 0}) do |totals, item|
      totals[:discount]    += item.discount
      totals[:gross]       += item.quantity * item.unit_price
      totals[:transaction] += item.local_orbit_seller_fee + item.market_seller_fee
      totals[:net]         += item.seller_net_total
      totals[:payment]     += item.payment_seller_fee
      totals
    end
  end
end
