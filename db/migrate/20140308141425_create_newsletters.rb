class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :subject
      t.text :body
      t.references :market, index: true
      t.string :image_uid
      t.string :header
      t.boolean :draft
      t.date :sent_on

      t.boolean :buyers
      t.boolean :sellers
      t.boolean :market_managers

      t.timestamps
    end
  end
end
