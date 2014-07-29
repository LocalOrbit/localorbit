class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string  :metric_code
      t.date    :effective_on
      t.string  :model_type
      t.integer :model_ids, array: true, null: false, default: []

      t.timestamps
    end

    add_index :metrics, [:metric_code, :model_type]
    add_index :metrics, :metric_code
    add_index :metrics, :effective_on
  end
end
