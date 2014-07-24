class AddUserTermsOfServiceAgreement < ActiveRecord::Migration
  def change
    add_column :users, :accepted_terms_of_service_at, :date
  end
end
