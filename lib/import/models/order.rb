require 'import/models/base'

module Imported
  class Order < ActiveRecord::Base
    self.table_name = "orders"

    has_many :order_payments, class_name: 'Imported::OrderPayment', inverse_of: :order
    has_many :payments, through: :order_payments, inverse_of: :orders

    has_many :items, class_name: "Imported::OrderItem", inverse_of: :order
    belongs_to :organization, class_name: "Imported::Organization", inverse_of: :orders
    belongs_to :market, class_name: "Imported::market", inverse_of: :orders
    belongs_to :delivery, class_name: "Imported::Delivery", inverse_of: :orders
  end
end

class Legacy::OrderPaymentStatus < Legacy::Base
  self.table_name = "lo_buyer_payment_statuses"
  self.primary_key = "lbps_id"
end

class Legacy::Order < Legacy::Base
  self.table_name = "lo_order"
  self.primary_key = "lo_oid"

  belongs_to :buyer_payment_status, class_name: "Legacy::OrderPaymentStatus", foreign_key: :lbps_id

  has_many :items, class_name: "Legacy::OrderItem", foreign_key: :lo_oid
  has_many :shipping_addresses, -> { where(address_type: "Shipping") }, class_name: "Legacy::OrderAddress", foreign_key: :lo_oid
  has_many :billing_addresses, -> { where(address_type: "Billing") }, class_name: "Legacy::OrderAddress", foreign_key: :lo_oid

  belongs_to :organization, class_name: "Legacy::Organization", foreign_key: :org_id
  belongs_to :market, class_name: "Legacy::Market", foreign_key: :domain_id

  has_one :delivery, class_name: "Legacy::Delivery", foreign_key: :lo_oid

  def import
    if order_date.present?
      attributes = {
        organization: imported_organization,
        delivery: imported_delivery,
        order_number: lo3_order_nbr,
        billing_organization_name: organization.name,
        billing_address: billing.street1,
        billing_city: billing.city,
        billing_state: billing.region.code,
        billing_state: billing.postcode,
        billing_phone: billing.telephone,
        placed_at: order_date,
        total_cost: grand_total,
        payment_method: imported_payment_method,
        payment_status: imported_payment_status,
        payment_note: payment_ref,
        notes: admin_notes,
        legacy_id: lo_oid
      }

      order = Imported::Order.where(legacy_id: lo_oid).first

      if order.nil?
        puts "- Creating order #{lo3_order_nbr}"
        order = Imported::Order.new(attributes)

        items.each do |item|
          imported = item.import
          order.items << imported if imported.present?
        end
      else
        puts "- Existing order #{order.order_number}"
        order.update(attributes)
        items.each {|i| i.import }
      end

      order
    end
  end

  def shipping
    shipping_addresses.first
  end

  def billing
    billing_addresses.first
  end

  def imported_organization
    Imported::Organization.where(legacy_id: organization.org_id).first
  end

  def imported_delivery
    delivery.import if delivery
  end

  def imported_payment_method
    if payment_method == "purchaseorder"
      "purchase order"
    else
      payment_method
    end
  end

  def imported_payment_status
    buyer_payment_status.try(:buyer_payment_status) || "unpaid"
  end

  # 2-letter region/state code. Example: "MI"
  def region_code
    region ? region.code : ""
  end
end
