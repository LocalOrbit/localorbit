module Admin
  class UsersController < AdminController
    include StickyFilters

    before_action :require_admin_or_market_manager
    before_action :lookup_manageable_user, only: [:edit, :update, :update_enabled]
    before_action :find_users, only: :index
    before_action :find_sticky_params, only: :index

    def index
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

    def update_enabled
      org = @user.organizations_including_suspended.find(params[:organization_id])


      if !current_user.can_manage_organization?(org)
        return redirect_to :back, alert: "You are unable to manage this organization."
      end

      join_association = @user.user_organizations.find_by(organization: org)

      if join_association.nil?
        redirect_to :back, alert: "Unable to update #{@user.decorate.display_name}"
      end

      if join_association.update_attributes(enabled: update_enabled_params[:enabled])
        redirect_to :back, notice: "Updated #{@user.decorate.display_name}"
      else
        redirect_to :back, alert: "Unable to update #{@user.decorate.display_name}"
      end
    end

    private

    def update_enabled_params
      params.permit(:organization_id, :enabled, :id)
    end

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
      @users = scope.includes(:managed_markets)
    end
  end
end
