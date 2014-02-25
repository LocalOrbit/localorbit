module ApplicationHelper
  def filter_link(object, param_name)
    params = request.query_parameters

    class_name = params[param_name] == object.id.to_s ? "current" : ""

    content_tag(:li, class: class_name) do
      link_to object.name, url_for(params.merge(param_name => object.id))
    end
  end
end
