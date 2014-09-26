class CreateSubscriptions < ActiveRecord::Migration
  class SubscriptionType < ActiveRecord::Base; end

  def change
    create_table :subscription_types do |t|
      t.string :keyword
      t.string :name
      t.timestamps
    end
    add_index :subscription_types, :keyword

    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :subscription_type_id
      t.string :token
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, [:user_id,:deleted_at]
    add_index :subscriptions, [:user_id, :subscription_type_id]
    add_index :subscriptions, :subscription_type_id
    add_index :subscriptions, :token

    SubscriptionType.reset_column_information

    reversible do |dir|
      dir.up do
        say_with_time "Inserting SubscriptionTypes 'fresh_sheet', 'newsletter'" do
          SubscriptionType.create! name: "Fresh Sheet", keyword: "fresh_sheet"
          SubscriptionType.create! name: "Newsletter", keyword: "newsletter"
          2
        end
      end
    end
  end
end
