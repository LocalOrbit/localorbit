class CreatePackingLabelsPrintables < ActiveRecord::Migration
  def change
    create_table :packing_labels_printables do |t|
      t.integer :user_id
      t.integer :delivery_id
      t.string :pdf_uid
      t.string :pdf_name

      t.timestamps
    end
  end
end
