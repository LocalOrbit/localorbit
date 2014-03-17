class AddTaglineAndBackgroundToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :tagline, :string
    add_column :markets, :background, :string
  end
end
