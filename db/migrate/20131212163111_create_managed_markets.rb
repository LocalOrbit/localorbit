class CreateManagedMarkets < ActiveRecord::Migration
  def change
    create_table :managed_markets do |t|
      t.integer :market_id
      t.integer :user_id

      t.timestamps
    end
  end
end
