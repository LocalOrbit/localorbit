class RemoveSendFreshsheetAndSendNewsletter < ActiveRecord::Migration
  def change
    remove_column :users, :send_freshsheet, :boolean, default: true, null: false
    remove_column :users, :send_newsletter, :boolean, default: true, null: false
  end
end
