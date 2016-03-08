class AddStripeStandaloneToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :stripe_standalone, :boolean
  end
end
