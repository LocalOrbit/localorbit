class AddPoPaymentTermToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :po_payment_term, :integer
  end
end
