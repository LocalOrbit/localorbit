module StickyFilters
  def sticky_parameters(parameters)
    path = request.path.split(".").first
    session[:sticky_parameters] ||= {}
    existing_parameters = (session[:sticky_parameters][path] || {}).with_indifferent_access

    # Clear parameters if given a clear key
    if parameters["clear"]
      existing_parameters = existing_parameters.slice("per_page")
      parameters = parameters.slice("per_page")
    end

    # Remove saved page if the user is on page 1
    existing_parameters.delete("page") if existing_parameters.present? && parameters["page"].nil?

    # Merge new keys into existing parameters
    new_parameters = existing_parameters.deep_merge(parameters)
    session[:sticky_parameters][path] = deep_remove_blank_keys(new_parameters)

    session[:sticky_parameters][path]
  end

  protected

  def deep_remove_blank_keys(hash)
    hash = hash.deep_dup

    hash.each_with_object(hash) do |(key, value), hash|
      if value.is_a?(Hash)
        hash[key] = deep_remove_blank_keys(value)
      else
        hash.delete(key) if value.blank? || (value.length == 1 && value[0] == "") || key.to_s =~ /.+%.+/
      end
    end
  end

  def find_sticky_params
    @query_params = sticky_parameters(request.query_parameters)
  end
end
