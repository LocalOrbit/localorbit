module Admin
  class OrganizationUsersController < AdminController
    include Users

    before_action :find_organization
    before_action :lookup_manageable_user, only: [:edit, :update]

    def index
    end

    def edit
    end

    def update
      original_email = @user.email

      if @user.update_attributes(user_params)
        redirect_to admin_organization_users_path(@organization), notice: "User saved successfully."
        UserMailer.delay.user_updated(@user, current_user, original_email)
      else
        render :edit
      end
    end

    def create
      market = current_market || @organization.original_market
      @invite_user = InviteUserToOrganization.perform(
        inviter: current_user,
        email: user_params[:email],
        organization: @organization,
        market: market)

      if @invite_user.success?
        redirect_to [:admin, @organization, :users], notice: "Sent invitation to #{@invite_user.user.email}"
      else
        redirect_to [:admin, @organization, :users], alert: @invite_user.message
      end
    end

    def destroy
      @user = @organization.users.find(params[:id])
      @organization.users.delete(@user)

      redirect_to [:admin, @organization, :users], notice: "Successfully removed #{@user.email}."
    end

    def invite
      user = @organization.users.find(params[:user_id])
      invite_user(user)

      redirect_to [:admin, @organization, :users], notice: "User #{user.decorate.display_name} Re-Invited"

    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation).reject {|_, v| v.empty? }
    end

    def find_organization
      @organization = current_user.managed_organizations.find(params[:organization_id])
    end
  end
end
