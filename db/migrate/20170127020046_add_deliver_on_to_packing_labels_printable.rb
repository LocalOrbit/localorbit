class AddDeliverOnToPackingLabelsPrintable < ActiveRecord::Migration
  def change
    add_column :packing_labels_printables, :deliver_on, :string
  end
end
