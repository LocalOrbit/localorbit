class AddGcModelToOrg < ActiveRecord::Migration
  def change
    add_column :organizations, :payment_model, :string, default: 'buysell'
  end
end
