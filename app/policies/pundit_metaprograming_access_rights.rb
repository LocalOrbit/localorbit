class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_activities
    @user.roles.select(:activities).distinct.map(&:activities).flatten
  end

  def inferred_activity(method)
    "#{@record.class.name.downcase}:#{method.to_s}"
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