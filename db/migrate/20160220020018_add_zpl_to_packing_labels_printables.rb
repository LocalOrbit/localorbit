class AddZplToPackingLabelsPrintables < ActiveRecord::Migration
  def change
    add_column :packing_labels_printables, :zpl, :text
    add_column :packing_labels_printables, :zpl_name, :string
  end
end
