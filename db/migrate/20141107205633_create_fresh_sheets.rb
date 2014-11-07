class CreateFreshSheets < ActiveRecord::Migration
  def change
    create_table :fresh_sheets do |t|
      t.integer :market_id
      t.integer :user_id
      t.text :note

      t.timestamps
    end

    add_index :fresh_sheets, [:market_id, :user_id]
  end
end
