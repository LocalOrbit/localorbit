module StickyFilters
  def sticky_parameters(parameters)
    path = request.path
    session[:sticky_parameters] ||= {}
    existing_parameters = session[:sticky_parameters][path]
    existing_parameters.delete("page") if parameters["page"].nil?
    session[:sticky_parameters][path] = existing_parameters.nil? ? parameters : existing_parameters.merge(parameters)
    session[:sticky_parameters][path].reject! {|key, value| value == "" || key == "clear" }
    session[:sticky_parameters][path]
  end

  def process_filter_clear_requests
    if request.query_parameters["clear"]
      session[:sticky_parameters][request.path] = {}
    end
  end
end
