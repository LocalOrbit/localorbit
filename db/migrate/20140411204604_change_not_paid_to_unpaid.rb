class ChangeNotPaidToUnpaid < ActiveRecord::Migration
  def up
    Order.where(payment_status: 'Not Paid').update_all(payment_status: 'unpaid')
  end

  def down
    Order.where(payment_status: 'unpaid').update_all(payment_status: 'Not Paid')
  end
end
