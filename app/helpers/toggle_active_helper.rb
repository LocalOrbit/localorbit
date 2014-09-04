module ToggleActiveHelper
  def toggle_active_button(resource)
    return unless resource.respond_to?(:active?)
    return unless current_user.admin? || current_user.can_manage?(resource)

    title = resource.active? ? "Deactivate" : "Activate"

    link_to_opts = {
      method: :patch,
      class: "btn btn--small btn--save"
    }

    link_to(
      title,
      [:admin, resource, :update_active, active: !resource.active?],
      link_to_opts
    )
  end
end
