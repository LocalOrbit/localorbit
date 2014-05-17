require 'import/models/base'

module Imported
  class OrderPayment < ActiveRecord::Base
    belongs_to :order, class_name: 'Imported::Order'
    belongs_to :payment, class_name: 'Imported::Payment'
  end

  class Payment < ActiveRecord::Base
    self.table_name = "payments"

    belongs_to :payee, polymorphic: true
    belongs_to :payer, polymorphic: true

    has_many :order_payments, class_name: 'Imported::OrderPayment', inverse_of: :payment
    has_many :orders, through: :order_payments, inverse_of: :payments
  end
end

class Legacy::Payment < Legacy::Base
  self.table_name = "v_payments_export"

  def import
    payment = Imported::Payment.find_by_legacy_id(payment_id)
    if payment.nil?
      puts "- Importing payment for #{payment_id}"
      payment = Imported::Payment.new(
        amount: total_payment,
        note: ref_nbr,
        status: 'paid',
        payment_method: payment_method,
        payment_type: imported_payment_type,
        created_at: Time.at(payment_date),
        updated_at: Time.at(payment_date),
        payee: imported_organization(to_org_id),
        payer: imported_organization(from_org_id),
        legacy_id: payment_id
      )

      order = Imported::Order.find_by_order_number(buyer_order_nbr)
      payment.orders << order if order.present?

    else
      puts "- Existing payment for #{payment_id}"
    end

    payment
  end

  def imported_payment_type
    case payable_type
    when /.*order$/
      "order"
    when /^service/
      "service"
    else
      payable_type
    end
  end

  def imported_organization(org)
    Imported::Organization.find_by_legacy_id(org) unless org == 1
  end
end
