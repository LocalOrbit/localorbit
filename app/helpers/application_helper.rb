module ApplicationHelper
  # Used in navigation to get to the users organization(s)
  def path_to_my_orgainzation
    organizations = current_user.managed_organizations
    if organizations.count == 1
      admin_organization_path(organizations.first)
    else
      admin_organizations_path
    end
  end

  def filter_list(collection, param_name)
    params = request.query_parameters

    content_tag(:ul, class: "filter-list", id: "product-filter-#{param_name}") do
      collection.each do |object|
        class_name = params[param_name] == object.id.to_s ? "current" : ""

        item = content_tag(:li, class: class_name) do
          concat link_to(object.name, params.merge(param_name => object.id))
          concat " "
          concat link_to("[clear]", params.merge(param_name.to_s => nil), class: 'clear-filter hide-when-open')
        end

        concat(item)
      end
    end
  end

  def edit_table_error_payload(obj)
    return nil unless obj
    {"error-payload" => obj.to_json, "id-prefix" => obj.class.to_s.downcase}
  end

  def link_to_or_span(name, options = {}, html_options = {}, &block)
    if current_page?(options)
      content_tag(:span, name, html_options, &block)
    else
      link_to name, options, html_options, &block
    end
  end

  def background_options
    files = Dir.glob(Rails.root.join('app/assets/images/backgrounds/*.jpg'))
    files.map{|name| [name.split(/[\/\.]/)[-2].titleize, name.split('/')[-1]] }
  end
end
