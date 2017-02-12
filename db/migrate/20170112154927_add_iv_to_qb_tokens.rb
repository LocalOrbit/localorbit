class AddIvToQbTokens < ActiveRecord::Migration
  def change
    add_column :qb_tokens, :encrypted_access_token_iv, :string
    add_column :qb_tokens, :encrypted_access_secret_iv, :string
    add_column :qb_tokens, :encrypted_realm_id_iv, :string
  end
end
