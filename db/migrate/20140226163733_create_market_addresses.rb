class CreateMarketAddresses < ActiveRecord::Migration
  def change
    create_table :market_addresses do |t|
      t.string :name,             null: false
      t.string :address,          null: false
      t.string :city,             null: false
      t.string :state,            null: false
      t.string :zip,              null: false
      t.integer :market_id,       null: false

      t.timestamps
    end
    
    add_index :market_addresses, :market_id
  end
end
