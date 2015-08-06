class AddAlternativeOrderFlagToMarkets < ActiveRecord::Migration
  def up
    add_column :markets, :alternative_order_page, :boolean, default: false, null: false
    zynga = Market.where("name like '%Zynga%'").first
    if zynga
      zynga.alternative_order_page = true
      zynga.update_attribute(:alternative_order_page, true)
    end
  end

  def down
    remove_column :markets, :alternative_order_page
  end
end
