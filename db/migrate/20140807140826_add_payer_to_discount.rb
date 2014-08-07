class AddPayerToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :payer, :integer, null: false, default: 0
  end
end
