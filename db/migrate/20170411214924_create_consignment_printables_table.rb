class CreateConsignmentPrintablesTable < ActiveRecord::Migration
  def change
    create_table :consignment_printables do |t|
      t.integer :user_id
      t.string :pdf_uid
      t.string :pdf_name

      t.timestamps
    end
  end
end
