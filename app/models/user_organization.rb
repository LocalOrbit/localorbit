class UserOrganization < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :user
  belongs_to :organization

  scope :enabled, -> { where(enabled: true) }
end
