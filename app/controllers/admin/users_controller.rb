module Admin
  class UsersController < AdminController
    def index
      @users = if current_user.admin?
        User.all
      else
        ids = current_user.managed_markets.map {|m| m.manager_ids }.flatten |
          current_user.managed_organizations.map {|o| o.user_ids }.flatten
        User.where(id: ids)
      end.periscope(request.query_parameters).page(params[:page]).per(params[:per_page])

      @users.includes(:managed_markets, :organizations)
    end
  end
end
