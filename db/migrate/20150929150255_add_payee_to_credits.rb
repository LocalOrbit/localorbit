class AddPayeeToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :payer_type, :string, null: false
    add_column :credits, :paying_org_id, :integer
    rename_column :credits, :percentage_or_fixed, :amount_type
  end
end
