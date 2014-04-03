module Admin
  class UsersController < AdminController
    def index
      if current_user.admin?
        @users = User.all
      else
        ids = current_user.managed_markets.map{|m| m.manager_ids }.flatten |
          current_user.managed_organizations.map{|o| o.user_ids }.flatten
        @users = User.where(id: ids)
      end

      @users.includes(:managed_markets, :organizations)
    end
  end

end
