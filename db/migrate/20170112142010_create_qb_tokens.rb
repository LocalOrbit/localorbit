class CreateQbTokens < ActiveRecord::Migration
  def change
    create_table :qb_tokens do |t|
      t.integer :organization_id
      t.string :encrypted_access_token
      t.string :encrypted_access_secret
      t.string :encrypted_realm_id
      t.datetime :token_expires_at
    end
  end
end
