class AddUnitDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :unit_description, :string
  end
end
