class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  def display_name
    name || email
  end

  def toggle_enabled_button
    return # Temporarily disables User Suspend button
    return unless current_user.can_manage_user?(self)
    title = enabled_for_organization?(context[:org]) ? "Suspend" : "Enable"
    status = enabled_for_organization?(context[:org]) ? "alert" : "notice"

    link_to_opts = {
        method: :patch,
        class: "btn btn--small #{status}"
    }

    link_to(
        title,
        update_enabled_admin_user_path(self, organization_id: context[:org].id, enabled: !enabled_for_organization?(context[:org])),
        link_to_opts
    )
  end
end
