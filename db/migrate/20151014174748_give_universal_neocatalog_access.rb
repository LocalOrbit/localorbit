class GiveUniversalNeocatalogAccess < ActiveRecord::Migration
  def up
    Market.update_all(alternative_order_page: true)
  end

  def down
    Market.where('name NOT LIKE ?', '%Zynga%').update_all(alternative_order_page: false)
  end
end
