class AddAllowSignupsToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :allow_signups, :boolean, default: true
  end
end
