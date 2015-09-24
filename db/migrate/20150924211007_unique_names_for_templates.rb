class UniqueNamesForTemplates < ActiveRecord::Migration
  def change
    add_index :order_templates, [:market_id, :name], unique: true
  end
end
