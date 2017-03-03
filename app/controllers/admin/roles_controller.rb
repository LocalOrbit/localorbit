class Admin::RolesController < AdminController
  before_action :find_role, except: [:index, :new, :create]

  def index
    if current_user.admin?
      @roles = Role.all.order(:name)
    else
      @roles = Role.where(organization_id: current_market.organization.id).order(:name)
    end
  end

  def show
    if current_user.admin?
      @role_actions = RoleAction.all.order(:section)
    else
      @role_actions = RoleAction.published.where("org_types @> '{#{current_user.primary_user_role}}'::character varying[] AND (plan_ids @> '{#{current_user.user_organizations.map(&:organization).compact.map(&:plan_id).compact.join(', ')}}'::character varying[])").order(:section)
    end
    if !@role.activities.empty?
      @act = @role_actions.select("id").where("lower(description) in (#{@role.activities.map { |i| "'" + i.to_s + "'" }.join(',')})")
    end
  end

  def new
    @role = Role.new
    if current_user.admin?
      @role_actions = RoleAction.all.order(:section)
    else
      @role_actions = RoleAction.published.where("org_types @> '{#{current_user.primary_user_role}}'::character varying[] AND (plan_ids @> '{#{current_user.user_organizations.map(&:organization).compact.map(&:plan_id).compact.join(', ')}}'::character varying[])").order(:section)
    end
  end

  def create
    act = RoleAction.select("lower(description) AS description").where(id: params[:role][:activities].map(&:to_i)).map(&:description)
    if current_user.admin?
      org_id = nil
    else
      org_id = current_market.organization.id
    end
    @role = Role.create(role_params.merge(:activities => act, :organization_id => org_id, :org_type => current_user.primary_user_role))
    redirect_to admin_roles_path, notice: "Role created"
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