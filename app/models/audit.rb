require 'audited/adapters/active_record/audit'

class Audited::Adapters::ActiveRecord::Audit < ActiveRecord::Base

  def user_name_or_email
    if username
      username
    elsif user
      user.name.present? ? user.name : user.email
    end
  end
end

# Alias constant for easier use
Audit = Audited::Adapters::ActiveRecord::Audit
