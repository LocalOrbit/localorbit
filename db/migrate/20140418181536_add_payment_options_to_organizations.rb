class AddPaymentOptionsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :allow_purchase_orders, :boolean
    add_column :organizations, :allow_credit_cards, :boolean
    add_column :organizations, :allow_ach, :boolean
  end
end
