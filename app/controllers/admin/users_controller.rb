module Admin
  class UsersController < AdminController
    def index
      if current_user.admin?
        @users = User.all
      else
        ids = current_user.markets.map{|m| m.managers.pluck(:id)}.flatten &
          current_user.managed_organizations.map{|o| o.users.pluck(:id) }
        @users = User.where(id: ids)
      end

      @users.includes(:managed_markets, :organizations)
    end
  end

end
