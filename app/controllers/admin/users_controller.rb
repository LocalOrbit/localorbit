module Admin
  class UsersController < AdminController
    def index
      @organization = current_user.managed_organizations.find(params[:organization_id])
    end

    def create
      @organization = current_user.managed_organizations.find(params[:organization_id])
      market = current_market || @organization.markets.first
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

    private

    def user_params
      params.require(:user).permit(:email)
    end
  end

end
