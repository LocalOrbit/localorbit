module ApplicationHelper
  def help_path
    "https://localorbit.zendesk.com/anonymous_requests/new"
  end

  # Used in navigation to get to the users organization(s)
  def path_to_my_organization
    organizations = current_user.managed_organizations
    if organizations.count == 1
      admin_organization_path(organizations.first)
    else
      admin_organizations_path
    end
  end

  def filter_list(collection, param_name)
    params = request.query_parameters

    content_tag(:ul, class: "filter-list", id: "product-filter-#{param_name}", :"data-count" => collection.count) do
      collection.each do |object|
        class_name = params[param_name] == object.id.to_s ? "current" : ""

        item = content_tag(:li, class: class_name) do
          concat link_to(object.name, params.merge(param_name => object.id))
          concat " "
          concat link_to('<i class="font-icon icon-clear pull-right"></i>'.html_safe, params.merge(param_name.to_s => nil), class: "clear-filter hide-when-open")
        end

        concat(item)
      end
    end
  end

  def edit_table_error_payload(obj)
    return nil unless obj
    {"error-payload" => obj.to_json, "id-prefix" => obj.class.to_s.downcase}
  end

  def link_to_or_span(name, options={}, html_options={}, &block)
    if similar_base_url_for_tab?(options)
      if html_options[:class].present?
        html_options[:class] += " current"
      else
        html_options[:class] = "current"
      end
      content_tag(:span, name, html_options, &block)
    else
      link_to name, options, html_options, &block
    end
  end

  # a matcher similar to current_page?(options) but crazier!
  # See also http://rubular.com/r/PVc6MLd5mL
  def similar_base_url_for_tab?(options)
    base_url = url_for.sub(/\/?(\d*|new)?(\?.*)?$/, "")
    regexp = %r{#{Regexp.escape(base_url)}(/(new|\d+(/edit)?)|)$}
    regexp =~ url_for(options)
  end

  def background_options
    files = Dir.glob(Rails.root.join("app/assets/images/backgrounds/*.jpg"))
    files.map {|name| [name.split(/[\/\.]/)[-2].titleize, name.split("/")[-1]] }
  end

  def color_mix (color_a = "#000000", color_b = "#ffffff")
    color_a.reverse!.chomp!('#').reverse!
    color_b.reverse!.chomp!('#').reverse!
    if color_a.length == 6 && color_b.length == 6

      r = (((color_a[0..1].hex - color_b[0..1].hex).abs / 2 ) + color_a[0..1].hex).to_s(16)
      g = (((color_a[2..3].hex - color_b[2..3].hex).abs / 2 ) + color_a[2..3].hex).to_s(16)
      b = (((color_a[4..5].hex - color_b[4..5].hex).abs / 2 ) + color_a[4..5].hex).to_s(16)
      return "##{r}#{g}#{b}"
    end
    return "##{color_a}"

  end
end
