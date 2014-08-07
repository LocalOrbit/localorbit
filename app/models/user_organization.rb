class UserOrganization < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :user
  belongs_to :organization
end
