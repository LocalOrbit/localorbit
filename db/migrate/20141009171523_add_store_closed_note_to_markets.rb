class AddStoreClosedNoteToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :store_closed_note, :text
  end
end
