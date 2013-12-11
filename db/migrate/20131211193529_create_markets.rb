class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.string  :name
      t.string  :subdomain
      t.string  :timezone
      t.boolean :active,       null: false, default: false
      t.string  :contact_name
      t.string  :contact_email
      t.string  :contact_phone
      t.string  :facebook
      t.string  :twitter
      t.text    :profile
      t.text    :policies

      t.timestamps
    end

    add_index :markets, :subdomain
  end
end
