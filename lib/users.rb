module Users
  def find_users
    scope = if current_user.admin?
              User.all
            else
              ids = current_user.managed_markets.map {|m| m.manager_ids }.flatten |
                  current_user.managed_organizations.map {|o| o.user_ids }.flatten
              User.where(id: ids)
            end
    @users = scope.includes(:managed_markets)
  end
end