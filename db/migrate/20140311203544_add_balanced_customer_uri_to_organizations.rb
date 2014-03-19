class AddBalancedCustomerUriToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :balanced_customer_uri, :string
  end
end
