module SuspendHelpers
  def suspend_user(opts={})
    get_user_organization(opts[:user], opts[:org]).update_attributes!(enabled: false)
  end

  def enable_user(opts={})
    get_user_organization(opts[:user], opts[:org]).update_attributes!(enabled: true)
  end

  private
  def get_user_organization(user, organization)
    uo = user.user_organizations.find_by(organization: organization)
    raise %(User "#{user.decorate.display_name}" is not in organization "#{organizations.name}") if uo.nil?
    uo
  end
end

RSpec.configure do |config|
  config.include SuspendHelpers
end
