module ToggleActiveHelper
  def toggle_active_button(resource, parent: nil)
    return unless resource.respond_to?(:active?)

    title = resource.active? ? "Deactivate" : "Activate"

    link_to_opts = {
      method: :patch,
      class: "btn btn--small btn--save"
    }

    path = [:update_active, :admin]
    if parent
      path << parent
    end
    path.concat([resource, active: !resource.active?])

    link_to(title, path, link_to_opts)
  end
end
