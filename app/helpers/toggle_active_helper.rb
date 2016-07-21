module ToggleActiveHelper
  def toggle_active_button(resource, parent: nil)
    return unless resource.respond_to?(:active?)
    
    link_to_opts = {
      method: :patch,
      class: "btn btn--small btn--save"
    }

    if( resource.try(:pending) )
      title = "Confirm"
      path = [:confirm_pending, :admin]
      if parent
        path << parent
      end
      path.concat([resource, pending: !resource.pending?])
    else
      if( resource.active? )
        title = "Deactivate"
      else
        title = "Activate"
      end

      path = [:update_active, :admin]
      if parent
        path << parent
      end
      path.concat([resource, active: !resource.active?])
    end

    link_to(title, path, link_to_opts)
  end
end
