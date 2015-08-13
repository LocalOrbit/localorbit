class SetGeneralProductUseAllDeliveriesDefault < ActiveRecord::Migration
  def change
    change_column_default :general_products, :use_all_deliveries, true
  end
end
