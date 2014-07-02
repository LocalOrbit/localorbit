module Admin
  class OrganizationUsersController < AdminController
    before_action :find_organization

    def index
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

    private

    def user_params
      params.require(:user).permit(:email)
    end

    def find_organization
      @organization = current_user.managed_organizations.find(params[:organization_id])
    end
  end
end
