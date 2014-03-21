class AddBalancedCustomerUriToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :balanced_customer_uri, :string
  end
end
