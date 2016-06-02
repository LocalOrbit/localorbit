class AddAttributesToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :buyer_org_type, :string
    add_column :organizations, :ownership_type, :string
    add_column :organizations, :non_profit, :boolean
    add_column :organizations, :professional_organizations, :string
  end
end
