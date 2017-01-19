class Admin::RolesController < AdminController
  before_action :find_role, except: [:index, :new, :create]

  def index
    @roles = Role.all.order(:activities)
  end

  def show
    @role_actions = RoleAction.all.order(:section)
    @act = @role_actions.select("id").where("lower(description) in (#{@role.activities.map { |i| "'" + i.to_s + "'" }.join(',')})")
  end

  def new
    @role = Role.new
    @role_actions = RoleAction.all
  end

  def create
    @role = Role.create(role_params)
  end

  def edit
  end

  def update

    act = RoleAction.select("lower(description) AS description").where(id: params[:role][:activities].map(&:to_i)).map(&:description)
    if @role.update_attributes(role_params.merge(:activities => act))
      redirect_to admin_roles_path, notice: "Role updated"
    else
      redirect_to admin_roles_path, alert: error
    end
  end

  def destroy

  end

  private

  def role_params
    params.require(:role).permit(:name, :activities, :description, :org_type)
  end

  def find_role
    @role = Role.find_by_id(params[:id])
  end

  def check_assigned_role

  end
end