module StickyFilters
  extend ActiveSupport::Concern

  def sticky_parameters(parameters)
    path = request.path
    session[:sticky_parameters] ||= {}
    existing_parameters = session[:sticky_parameters][path]
    session[:sticky_parameters][path] = existing_parameters.nil? ? parameters : existing_parameters.merge(parameters)
    session[:sticky_parameters][path].reject! {|key, value| value == "" }
    session[:sticky_parameters][path]
  end

  def clear_sticky_parameters
    session[:sticky_parameters][path] = {}
  end
end
