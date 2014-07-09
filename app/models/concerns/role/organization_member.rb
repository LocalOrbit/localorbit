module Role
  module OrganizationMember
    extend ActiveSupport::Concern

    def admin?
      false
    end
  end
end
