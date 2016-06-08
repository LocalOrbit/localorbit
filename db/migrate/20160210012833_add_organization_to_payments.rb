class AddOrganizationToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :organization_id, :integer
  end
end
