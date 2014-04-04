class AddUseAllDeliveriesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :use_all_deliveries, :boolean, default: true
  end
end
