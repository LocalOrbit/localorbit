class AddGcModelToOrg < ActiveRecord::Migration
  def change
    add_column :orgs, :payment_model, :string, default: 'buysell'
  end
end
