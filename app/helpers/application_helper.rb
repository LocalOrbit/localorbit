module ApplicationHelper
  def filter_list(collection, param_name)
    params = request.query_parameters

    content_tag(:ul, id: "product-filter-#{param_name}") do
      collection.each do |object|
        class_name = params[param_name] == object.id.to_s ? "current" : ""

        item = content_tag(:li, class: class_name) do
          link_to object.name, url_for(params.merge(param_name => object.id))
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
end
