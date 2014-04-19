class AddDefaultPaymentOptionsToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :default_allow_purchase_orders, :boolean, default: false
    add_column :markets, :default_allow_credit_cards, :boolean, default: true
    add_column :markets, :default_allow_ach, :boolean, default: true
  end
end
