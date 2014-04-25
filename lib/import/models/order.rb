require 'import/models/base'

module Imported
  class Order < ActiveRecord::Base
    self.table_name = "orders"

    has_many :items, class_name: "Imported::OrderItem", inverse_of: :order
  end
end

class Legacy::Order < Legacy::Base
  self.table_name = "lo_order"
  self.primary_key = "lo_oid"

  has_many :items, class_name: "Legacy::OrderItem", foreign_key: :lo_oid
  has_many :shipping_addresses, -> { where(address_type: "Shipping") }, class_name: "Legacy::OrderAddress", foreign_key: :lo_oid
  has_many :billing_addresses, -> { where(address_type: "Billing") }, class_name: "Legacy::OrderAddress", foreign_key: :lo_oid

  belongs_to :organization, class_name: "Legacy::Organization", foreign_key: :org_id
  belongs_to :market, class_name: "Legacy::Market", foreign_key: :domain_id

  def import
    order = Imported::Order.where(legacy_id: lo_oid).first
    if order.nil?
      order = Imported::Order.new(
        order_number: lo3_order_number,
        billing_organization_name: buyer_name,
        placed_at: order_date,
        total_cost: grand_total,
        payment_method: payment_method,
        payment_note: payment_ref,
        notes: admin_notes,
      )
    end

    order
  end

  def shipping
    shipping_addresses.first
  end

  def billing
    billing_addresses.first
  end
end
