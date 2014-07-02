module Admin
  class UsersController < AdminController
    include StickyFilters

    def index
      @query_params = sticky_parameters(request.query_parameters)

      @users = if current_user.admin?
        User.all
      else
        ids = current_user.managed_markets.map {|m| m.manager_ids }.flatten |
          current_user.managed_organizations.map {|o| o.user_ids }.flatten
        User.where(id: ids)
      end.periscope(@query_params).page(params[:page]).per(@query_params[:per_page])

      @users.includes(:managed_markets, :organizations)
    end
  end
end
