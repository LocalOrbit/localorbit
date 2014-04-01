class CreateSequence < ActiveRecord::Migration
  def change
    create_table :sequences do |t|
      t.string "name"
      t.integer "value", null: false, default: 0
    end

    add_index :sequences, :name, unique: true
  end
end
