class AddStripeStandaloneToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :stripe_standalone, :boolean
    add_column :markets, :legacy_stripe_account_id, :string
  end
end
