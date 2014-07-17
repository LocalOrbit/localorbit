module Admin
  class UsersController < AdminController
    include StickyFilters

    before_action :require_admin_or_market_manager
    before_action :lookup_manageable_user, only: [:edit, :update]

    def edit
    end

    def update
      original_email = @user.email

      if @user.update_attributes(user_params)
        redirect_to admin_users_path, notice: "User saved successfully."
        UserMailer.delay.user_updated(@user, current_user, original_email)
      else
        render :edit
      end
    end

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

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation).reject {|k,v| v.empty?}
    end
  end
end
