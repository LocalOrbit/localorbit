class AddPaymentOptionsToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :allow_credit_cards, :boolean, default: true
    add_column :markets, :allow_purchase_orders, :boolean, default: true
    add_column :markets, :allow_ach, :boolean, default: true
  end
end
