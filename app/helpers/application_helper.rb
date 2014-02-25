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
end
