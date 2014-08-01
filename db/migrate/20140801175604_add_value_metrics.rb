class AddValueMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :value, :decimal
  end
end
