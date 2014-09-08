module ToggleActiveHelper
  def toggle_active_button(resource)
    return unless resource.respond_to?(:active?)

    title = resource.active? ? "Deactivate" : "Activate"

    link_to_opts = {
      method: :patch,
      class: "btn btn--small btn--save"
    }

    link_to(
      title,
      [:update_active, :admin, resource, active: !resource.active?],
      link_to_opts
    )
  end
end
