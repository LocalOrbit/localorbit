require 'import/models/base'
class Import::User < Import::Base
  self.table_name = "customer_entity"
  self.primary_key = "entity_id"

  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id

  def import
    user = ::User.where("lower(email) = ?", email.downcase).first

    if user.nil? && email =~ /\A\S+@.+\.\S+\z/
      user = ::User.create(
        email: email,
        password: 'imported1',
        password_confirmation: 'imported1',
        role: 'user'
      )
    end

    user
  end
end
