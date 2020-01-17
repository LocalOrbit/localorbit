class RemoveStripeStandaloneFromMarkets < ActiveRecord::Migration
  def change
    remove_column :markets, :stripe_standalone, :boolean
    remove_column :markets, :balanced_customer_uri, :string
    remove_column :markets, :balanced_underwritten, :boolean
    
    remove_column :organizations, :balanced_customer_uri, :string
    remove_column :organizations, :balanced_underwritten, :boolean

    remove_column :bank_accounts, :balanced_uri, :string
    remove_column :bank_accounts, :balanced_verification_uri, :string

    remove_column :payments, :balanced_uri, :string
  end
end
