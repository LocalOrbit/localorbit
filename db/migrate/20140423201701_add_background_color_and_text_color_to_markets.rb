class AddBackgroundColorAndTextColorToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :background_color, :string
    add_column :markets, :text_color, :string
  end
end
