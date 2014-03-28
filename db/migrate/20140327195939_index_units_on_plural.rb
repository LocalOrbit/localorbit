class IndexUnitsOnPlural < ActiveRecord::Migration
  def change
    add_index :units, :plural
  end
end
