module Admin
  class UsersController < AdminController
    include StickyFilters
    include Users

    before_action :require_admin_or_market_manager
    before_action :lookup_manageable_user, only: [:edit, :update, :update_enabled]
    before_action :find_users, only: :index
    before_action :find_sticky_params, only: :index

    def index
      if params["clear"]
        redirect_to url_for(params.except(:clear))
      else
        @users = @users.periscope(@query_params).page(params[:page]).per(@query_params[:per_page])
      end
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
      target_orgs = @user.organizations_including_suspended.find(update_enabled_params[:organization_ids])
      target_orgs = target_orgs.select {|o| current_user.can_manage_organization?(o) }

      user_org_associations = @user.user_organizations.where(organization_id: target_orgs.map(&:id))

      if user_org_associations.empty?
        redirect_to :back, alert: "Unable to update #{@user.decorate.display_name}"
        return
      end

      failed = []
      user_org_associations.each do |uo|
        unless uo.update_attributes(enabled: update_enabled_params[:enabled])
          failed << uo
        end
      end

      if failed.empty?
        redirect_to :back, notice: "Updated #{@user.decorate.display_name}"
      else
        redirect_to :back, alert: "Unable to update all affiliations for #{@user.decorate.display_name}"
      end
    end

    def confirm
      user = User.find(params[:user_id])
      confirm_user(user)

      redirect_to [:admin, :users], notice: "User #{user.decorate.display_name} Confirmed"
    end

    def invite
      user = User.find(params[:user_id])
      invite_user(user)

      redirect_to [:admin, :users], notice: "User #{user.decorate.display_name} Re-Invited"

    end

    private

    def update_enabled_params
      params.permit(:enabled, :id, organization_ids: [])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation).reject {|_, v| v.empty? }
    end
  end
end
