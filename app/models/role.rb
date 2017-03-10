class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  validates :name, presence: true

  def role_org
    organization_id.nil? ? ' (All)' : ' (' + Organization.find_by_id(organization_id).name + ')'
  end
end