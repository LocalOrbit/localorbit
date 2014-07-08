require "import/models/base"

module Imported
  class OrderPayment < ActiveRecord::Base
    belongs_to :order, class_name: "Imported::Order"
    belongs_to :payment, class_name: "Imported::Payment"
  end

  class Payment < ActiveRecord::Base
    self.table_name = "payments"

    belongs_to :payee, polymorphic: true
    belongs_to :payer, polymorphic: true
    belongs_to :market, class_name: "Imported::Market"

    has_many :order_payments, class_name: "Imported::OrderPayment", inverse_of: :payment
    has_many :orders, through: :order_payments, inverse_of: :payments
  end
end

class Legacy::Payment < Legacy::Base
  self.table_name = "v_payments_export"

  def import(market)
    attributes = {
      amount: total_payment,
      note: ref_nbr,
      status: "paid",
      payment_method: imported_payment_method,
      payment_type: imported_payment_type,
      created_at: Time.at(payment_date),
      updated_at: Time.at(payment_date),
      payee: imported_entity(to_org_id),
      payer: imported_entity(from_org_id),
      legacy_id: payment_id,
      market: market
    }

    payment = Imported::Payment.find_by_legacy_id(payment_id)
    if payment.nil?
      puts "- Creating payment: #{attributes[:payer].try(:name) || "localorbit"} => #{attributes[:payee].try(:name) || "localorbit"}"
      payment = Imported::Payment.new(attributes)

      if imported_payment_type == "order"
        order = Imported::Order.find_by_order_number(buyer_order_nbr)
        payment.orders << order if order.present?
      end
    else
      puts "- Updating payment: #{attributes[:payer].try(:name) || "localorbit"} => #{attributes[:payee].try(:name) || "localorbit"}"
      payment.update(attributes)
    end

    payment
  end

  def imported_payment_method
    if payment_method == "purchaseorder"
      "purchase order"
    else
      payment_method.try(:downcase)
    end
  end

  def imported_payment_type
    case payable_type
    when /.*order$/
      "order"
    when /^service/
      "service"
    else
      payable_type.try(:downcase)
    end
  end

  def imported_entity(org)
    entity = Imported::Organization.find_by_legacy_id(org) unless org == 1
    if imported_payment_type == "order"
      entity
    elsif entity.present?
      Imported::Market.find_by_name(entity.name) || entity
    end
  end
end
