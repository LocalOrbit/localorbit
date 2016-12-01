class AddBuyerToTemplate < ActiveRecord::Migration
  def change
    add_column :order_templates, :buyer_id, :integer
  end
end
