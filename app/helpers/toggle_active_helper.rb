# KXM This helper is leveraged by market and organization resources.  It may be that orgs eventually get a pending status, but until then (and likely subject to further discussion) all reference to 'pending' should be tried, and all everything should be abstracted.  Perhaps a different method?  Or a call to a traffic cop method that does a little intellegent branching?  Does it make sense to split out the 'pending' check to a different helper entirely (this, of course, would require modifications to any view that may leverage the 'pending' check)
module ToggleActiveHelper
  def toggle_active_button(resource, parent: nil)
=begin
    # KXM Delete this code upon acceptance
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
      # KXM Couldn't get this path working like the one below it. Any idea why?
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
