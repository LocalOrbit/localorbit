class Admin::RolesController < AdminController
  before_action :find_role, except: [:index, :new, :create]
  before_action :find_role_actions

  def index
    if current_user.admin?
      @roles = Role.all.order(:name)
    else
      @roles = Role.where(organization_id: current_market.organization.id).order(:name)
    end
  end

  def show
    if !@role.activities.empty?
      @act = @role_actions.select("id").where("lower(description) in (#{@role.activities.map { |i| "'" + i.to_s + "'" }.join(',')})")
    end
  end

  def new
    @role = Role.new
  end

  def create
    if !params[:role][:activities].nil?
      act = RoleAction.select("lower(description) AS description").where(id: params[:role][:activities].map(&:to_i)).map(&:description)
      if current_user.admin?
        org_id = nil
      else
        org_id = current_market.organization.id
      end
      @role = Role.create(role_params.merge(:activities => act, :organization_id => org_id, :org_type => current_user.primary_user_role))
      if @role.errors.empty?
        redirect_to admin_roles_path, notice: "Successfully added role"
      else
        redirect_to new_admin_role_path, alert: "Role Name can't be blank"
      end
    else
      redirect_to new_admin_role_path, alert: "No Permissions Selected"
    end
  end

  def edit
  end

  def update
    if !params[:role][:activities].nil?
      act = RoleAction.select("lower(description) AS description").where(id: params[:role][:activities].map(&:to_i)).map(&:description)
      if @role.update_attributes(role_params.merge(:activities => act))
        redirect_to admin_roles_path, notice: "Successfully updated role"
      else
        redirect_to admin_role_path, alert: "Unable to update role"
      end
    else
      redirect_to admin_role_path, alert: "Unable to update role"
    end
  end

  def destroy
    if Role.delete(params[:id])
      redirect_to admin_roles_path, notice: "Successfully removed role"
    else
      redirect_to admin_roles_path, alert: "Unable to remove role"
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, :description, :org_type, activities:[])
  end

  def find_role
    @role = Role.find_by_id(params[:id])
  end

  def find_role_actions
    if current_user.admin?
      @role_actions = RoleAction.all.order(:section)
    else
      @role_actions = RoleAction.published.where("org_types @> ?::character varying[] AND (plan_ids @> ?::character varying[])","{#{current_user.primary_user_role}}","{#{current_user.user_organizations.map(&:organization).compact.map(&:plan_id).compact.join(', ')}}").order(:section)
    end
  end
end