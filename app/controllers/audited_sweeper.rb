require "audited/sweeper"

class Audited::Sweeper < ActionController::Caching::Sweeper
  def before_create_with_masquerade(audit)
    before_create_without_masquerade(audit)

    if controller.try(:user_masquerade?)
      user_id = controller.try(:session).try(:[], :devise_masquerade_user)
      audit.masquerader_id = user_id
      username = User.select(:name).find_by(id: user_id).try(:name)
      audit.masquerader_username = username
    end
  end

  alias_method_chain :before_create, :masquerade
end
