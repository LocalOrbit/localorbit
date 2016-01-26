class Admin::RolesController < AdminController

  def index
    @roles = Role.all
  end

  def show
    @role = Role.find(params[:id])
    @role_actions = RoleAction.all
  end

  def new
    @role = Role.new
    @role_actions = RoleAction.all
  end

  def create
    @role = Role.create(role_params)
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    if @role.update_attributes(role_params)
      redirect_to [:admin, @role, :role], notice: "Role updated"
    else
      redirect_to [:admin, @role, :role], alert: error
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, :activities)
  end
end