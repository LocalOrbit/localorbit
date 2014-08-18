module Admin
  class UsersController < AdminController
    include StickyFilters

    before_action :require_admin_or_market_manager, except: [:unimpersonate]
    before_action :lookup_manageable_user, only: [:edit, :update]
    before_action :find_users, only: :index

    def index
      @query_params = sticky_parameters(request.query_parameters)
      @users = @users.periscope(@query_params).page(params[:page]).per(@query_params[:per_page])
    end

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

    def impersonate
      if user = User.where(id: params[:id]).first
        session[:doing_business_as] = user.id
      end

      redirect_to root_path
    end

    def unimpersonate
      if session[:doing_business_as].present?
        session[:doing_business_as] = nil
        redirect_to admin_users_path
      else
        redirect_to root_path
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation).reject {|_, v| v.empty? }
    end

    def find_users
      scope = if current_user.admin?
        User.all
      else
        ids = current_user.managed_markets.map {|m| m.manager_ids }.flatten |
          current_user.managed_organizations.map {|o| o.user_ids }.flatten
        User.where(id: ids)
      end
      @users = scope.includes(:managed_markets, :organizations)
    end
  end
end
