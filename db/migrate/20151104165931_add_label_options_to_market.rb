class AddLabelOptionsToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :product_label_format, :integer, default:4
    add_column :markets, :print_multiple_labels_per_item, :boolean, default:false
  end
end
