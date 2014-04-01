class AddEmailOptOutsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_freshsheet, :boolean, default: true, null: false
    add_column :users, :send_newsletter, :boolean, default: true, null: false

    add_index :users, :send_freshsheet
    add_index :users, :send_newsletter
  end
end
