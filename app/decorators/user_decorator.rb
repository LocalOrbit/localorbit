class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def display_name
    name || email
  end

  def toggle_enabled_button
    return unless current_user.can_manage_user?(self)

    title = enabled_for_organization?(context[:org]) ? "Suspend" : "Enable"
    status = enabled_for_organization?(context[:org]) ? "alert" : "notice"

    toggle_enabled_html(title, status, [context[:org]], !enabled_for_organization?(context[:org]))
  end

  def global_toggle_enabled_button
    return unless current_user.can_manage_user?(self)

    title, status = nil
    is_enabled = (organizations.count > suspended_organizations.count)

    if is_enabled
      title = "Suspend"
      status = "alert"
    else
      title = "Enable"
      status = "notice"
    end

    toggle_enabled_html(title, status, user.organizations_including_suspended, !is_enabled)
  end

  private

  def toggle_enabled_html(title, status, target_orgs, state)
    link_to_opts = {
      method: :patch,
      class: "btn btn--small #{status}"
    }

    link_to(
      title,
      update_enabled_admin_user_path(self, organization_ids: target_orgs.pluck(:id), enabled: state, method: :patch),
      link_to_opts
    )
  end
end
