require 'net/http'
require 'tempfile'
require 'uri'

module ApplicationHelper
  def can_access?(flag)
    current_user.admin? || current_user.managed_markets.any? {|m| m.organization.plan[flag.to_sym] }
  end

  def organization_can_access?(organization, flag)
    if organization
      organization.markets.any? {|m| m.organization.plan[flag.to_sym]}
    end
  end

  def pdf_asset_url(asset)
    path = asset_path(asset)
    "#{ENV.fetch('PDF_ASSET_HOST')}#{path}"
  end

  # Used in navigation to get to the users organization(s)
  def link_to_my_organization
    org_count = current_user.managed_organizations(include_suspended: true).count
    first_org = current_user.managed_organizations.first

    path = if org_count == 1 && first_org.present?
      admin_organization_path(first_org)
    else
      organizations_path
    end

    link_to_or_span(raw('<i class="font-icon" data-icon="&#xe027;"></i>') + "Your Organization".pluralize(org_count), path)
  end

  def show_financials?(user, market)
    user.admin? || user.market_manager? || user.seller? || (user.buyer_only? && user.managed_organizations.where(allow_purchase_orders: true).any? && market.try(:allow_purchase_orders?))
  end

  def column_sort_classes(column)
    if request.query_parameters["sort"]
      col, dir = request.query_parameters["sort"].downcase.split("-")
      result = []
      if column == col
        result << "sorted"
        result << (dir == "desc" ? "headerSortDown" : "headerSortUp")
      end
      result.join(" ")
    end
  end

  def can_reset?(params)
    params.any? {|key, _| key != "sort" && key != "page"  && key != "q"}
  end

  def deep_hash( obj, key )
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key]
    elsif obj.respond_to?(:each)
      r = nil
      obj.find{ |*a| r = deep_hash( a.last,key ) }
      r
    end
  end

  def append_sticky_class(search_key, class_string = '', defaults = {})
    # Start and end dates (among others) are in q, but also (and incorrectly) higher up...
    # limit the initial scope to account for this duality
    # request.path provides the initial context
    search_result = deep_hash(session[:sticky_parameters][request.path]['q'], search_key)

    if search_result == nil
      search_result = deep_hash(session[:sticky_parameters][request.path], search_key)
    end

    # Having searched, check if a filter is set...
    if search_result != '' && !!search_result
      # ...and further filter any defaults
      if !defaults.empty?
        defaults.each do |default|
          # This currently only applies to dates, and this code makes
          # the comparison more robust
          if search_result.to_date.to_s == default.to_date.to_s
            # Explicit return here short circuits the call as soon as
            # a fail condition is met.  That's what we want.
            return class_string
          end
        end
      end
      class_string = class_string == '' ? 'set_filter' : class_string += ' set_filter'
    else
      class_string
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
    if similar_base_url_for_tab?(url_for, options)
      if html_options[:class].present?
        html_options[:class] += " current"
      else
        html_options[:class] = "current"
      end
      tag = html_options[:tag] || :span
      content_tag(tag, name, html_options, &block)
    else
      link_to name, options, html_options, &block
    end
  end

  # a matcher similar to current_page?(options) but crazier!
  # See also http://rubular.com/r/PVc6MLd5mL
  def similar_base_url_for_tab?(current_url, options)
    base_url = current_url.sub(/\/?(\d+(\/edit)?|new|)?(\?.*)?$/, "")
    regexp = %r{#{Regexp.escape(base_url)}(/(new|\d+(/edit)?)|)$}
    !!(regexp =~ url_for(options))
  end

  def background_options
    files = Dir.glob(Rails.root.join("app/assets/images/backgrounds/*.jpg"))
    files.map {|name| [name.split(/[\/\.]/)[-2].titleize, name.split("/")[-1]] }
  end

  def hex_to_rgba(color, opacity=1)
    if color
      color = color.sub(/^#/, "")
      c = Color::RGB.by_hex(color)
      "rgba(#{c.red.round},#{c.green.round},#{c.blue.round},#{opacity})"
    end
  end

  def hex_to_hsl(color)
    color = color.sub(/^#/, "")
    Color::RGB.by_hex(color).to_hsl
  end

  def color_mix(color="#000000", percentage=50)
    hsl = hex_to_hsl(color)
    lum = hsl.luminosity + percentage
    lum = [lum, 100].min
    lum = [lum, 0].max
    hsl.luminosity = lum
    hsl.css_hsl
  end

  def svg_icon
    svg = "<svg class='icon' width='100%' height='100%' viewBox='0 0 513 395' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>
        <g stroke='none' stroke-width='1' fill='none' fill-rule='evenodd'>
            <path d='M237.816115,36.6541111 L197.922377,78.7431616 L40.4270465,78.7431616 L40.2069509,355.476693 L394.699128,355.818123 L394.730167,236.791553 L432.885715,217.846401 L432.97601,394.066788 L1.31775185,394.255844 L0.753404161,40.1953928 L237.816115,36.6541111 Z M198.023963,198.503381 C144.162619,237.172479 81.6272494,313.940703 81.6272494,313.940703 C81.6272494,313.940703 102.812873,165.934885 179.194502,119.790994 C255.576132,73.6471038 335.724795,78.683905 335.724795,78.683905 L336.478199,0.70516348 L512.255573,119.790991 L336.348399,235.719292 L336.537456,159.834281 C336.537456,159.834281 251.885306,159.834283 198.023963,198.503381 Z'></path>
        </g>
    </svg>"

    svg
  end

  def ensure_full_url(path)
    if path =~ /^http/
      path
    else
      request or raise("ensure_full_url requires url_info or request to be set")
      "#{request.base_url}#{path}"
    end
  end

  def save_to_var(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      resp = http.get(uri.path)
      resp.body
    end
  end

  def yes_no(boolean)
    boolean ? "Yes" : "No"
  end
end
