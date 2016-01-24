class Admin::RolesController < AdminController

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
    @role_actions = RoleAction.all
  end

  def create
    @role = Role.create(role_params)
  end

  private

  def role_params
    params.require(:role).permit(:name, :activities)
  end
end