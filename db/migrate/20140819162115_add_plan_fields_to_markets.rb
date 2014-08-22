class AddPlanFieldsToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :plan_start_at,        :datetime
    add_column :markets, :plan_interval,        :integer, default: 1,   null: false
    add_column :markets, :plan_fee,             :decimal, default: 0.0, null: false, precision: 7, scale: 2
    add_column :markets, :plan_bank_account_id, :integer
  end
end
