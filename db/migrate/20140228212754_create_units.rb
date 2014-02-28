class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :singular
      t.string :plural

      t.timestamps
    end
  end
end
