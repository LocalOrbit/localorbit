module ToggleActiveHelper
  def toggle_active_button(resource, parent: nil)
=begin
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
=end
    return unless resource.respond_to?(:active?)
    
    if resource.name == 'KXM Market'
      debug = true && false
    end
    
    link_to_opts = {
      method: :patch,
      class: "btn btn--small btn--save"
    }

    if( resource.pending? )
      title = "Confirm"
      # KXM Couldn't get this working like the one below it. Any idea why?
      path = "/admin/markets/#{resource.id}/confirm_pending?pending=false"
      #path = [:confirm_pending, :admin]
      if parent
        path << parent
      end
      #path.concat([resource, pending: !resource.pending?])
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

    binding.pry if debug

    link_to(title, path, link_to_opts)
  end
end
