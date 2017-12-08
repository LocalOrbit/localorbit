class AddBackgroundColorAndTextColorToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :background_color, :string, default: '#ffffff'
    add_column :markets, :text_color, :string, default: '#46639c'
  end
end
