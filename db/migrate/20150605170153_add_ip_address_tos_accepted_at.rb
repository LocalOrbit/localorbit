class AddIpAddressTosAcceptedAt < ActiveRecord::Migration
  def change
  	add_column :users, :accepted_terms_of_service_from, :string
  end
end
