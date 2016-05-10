class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_activities
    if @user.roles.count > 0
      @user.roles.select(:activities).where(org_type: @user.primary_user_role).distinct.map(&:activities).flatten
    else
      RoleAction.select('lower(description) AS description').where("org_type @> '{#{@user.primary_user_role}}'::character varying[] AND (plan_ids is null OR plan_ids @> '{#{@user.user_organizations.map(&:organization).map(&:plan_id).compact.join(', ')}}'::character varying[])").distinct.map(&:description).flatten
    end
  end

  def inferred_activity(method)
    "#{@record.to_s.downcase}:#{method.to_s}"
  end

  def method_missing(name,*args)
    if name.to_s.last == '?'
      user_activities.include?(inferred_activity(name.to_s.gsub('?','')))
    else
      super
    end
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
end