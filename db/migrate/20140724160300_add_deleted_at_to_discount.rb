class AddDeletedAtToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :deleted_at, :datetime
  end
end
