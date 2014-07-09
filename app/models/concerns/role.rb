module Role
  def self.for(user: user, market: market)
    if user.role == "admin"
      Role::Admin
    elsif market.managers.include?(user)
      Role::MarketManager
    elsif market.organizations.joins(:users).where(users: {id: user.id}).count > 0
      Role::OrganizationMember
    else
      raise(User::RoleError)
    end
  end
end
