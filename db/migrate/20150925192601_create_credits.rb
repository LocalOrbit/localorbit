class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.integer  :order_id, null: false
      t.integer  :user_id, null: false
      t.string   :percentage_or_fixed, null: false
      t.decimal  :amount, null: false
      t.text     :notes

      t.timestamps
    end
  end
end
