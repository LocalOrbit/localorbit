class AddPaymentProviderToOrganization < ActiveRecord::Migration
  class Organization < ActiveRecord::Base
  end

  def up
    add_column :organizations, :payment_provider, :string

    Organization.reset_column_information
    for organization in Organization.all
      organization.update_attribute(:payment_provider, 'stripe') if organization.org_type == 'M'
    end
  end

  def down
    remove_column :organizations, :payment_provider
  end
end
