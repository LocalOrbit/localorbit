class AddPaymentStatusToOrderItem < ActiveRecord::Migration
  class Order < ActiveRecord::Base;
    has_many :order_items
  end

  def up
    add_column :order_items, :payment_status, :string, default: 'unpaid'

    Order.all.each do |o|
      o.order_items.update_all(payment_status: o.payment_status)
    end
  end

  def down
    remove_column :order_items, :payment_status
  end
end
