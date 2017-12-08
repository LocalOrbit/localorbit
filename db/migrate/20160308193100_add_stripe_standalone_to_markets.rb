class AddStripeStandaloneToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :stripe_standalone, :boolean, default: true
    add_column :markets, :legacy_stripe_account_id, :string
  end
end
