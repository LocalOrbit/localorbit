class SetPoPaymentTermDefault < ActiveRecord::Migration
  class Market < ActiveRecord::Base; end;
  def up
    change_column :markets, :po_payment_term, :integer, default: 14, null: false
    Market.where(po_payment_term: nil).update_all(po_payment_term: 14)
  end

  def down
    change_column :markets, :po_payment_term, :integer, default: nil, null: true
  end
end
