require "import/models/base"
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

    user_details = {
      email: email,
      name: imported_name,
      password: "imported1",
      password_confirmation: "imported1",
      role: "user",
      confirmed_at: Time.current
    }

    if user.nil? && email =~ /\A\S+@.+\.\S+\z/
      puts "- Creating user: #{email}"
      user = ::User.create(user_details)
    else
      puts "- Updating existing user: #{email}"
      user.update(user_details)
    end

    user
  end

  def imported_name
    "#{first_name} #{last_name}"
  end
end
