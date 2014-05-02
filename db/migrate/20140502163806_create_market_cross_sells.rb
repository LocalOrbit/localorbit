class CreateMarketCrossSells < ActiveRecord::Migration
  def change
    create_table :market_cross_sells do |t|
      t.integer :source_market_id
      t.integer :destination_market_id
      t.timestamps
    end
  end
end
