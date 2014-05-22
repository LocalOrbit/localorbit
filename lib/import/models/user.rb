require 'import/models/base'
class Legacy::User < Legacy::Base
  class UserOrganization < ActiveRecord::Base
    self.table_name = "user_organizations"

    belongs_to :user
    belongs_to :organization, class_name: "Legacy::Organization::Organization"
  end

  self.table_name = "customer_entity"
  self.primary_key = "entity_id"

  belongs_to :organization, class_name: "Legacy::Organization", foreign_key: :org_id

  def import
    user = ::User.where("lower(email) = ?", email.downcase).first

    if user.nil? && email =~ /\A\S+@.+\.\S+\z/
      puts "- Creating user: #{email}"
      user = ::User.create(
        email: email,
        password: 'imported1',
        password_confirmation: 'imported1',
        role: 'user',
        confirmed_at: Time.current
      )
    end

    user
  end
end
