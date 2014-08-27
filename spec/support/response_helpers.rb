module ResponseHelpers
  class MultipleRootError < StandardError
  end

  # Return the parsed JSON from the response
  def json
    @json ||= JSON.parse(body)
  end

  # Return the value at the root node of the resopnse
  def resource
    @resource ||= json[resource_key]
  end

  alias_method :collection, :resource

  # Return the ID for the resource
  def resource_id
    @id ||= resource["id"]
  end

  # Return the IDs for each resource in the collection
  def collection_ids
    @ids ||= collection.map {|e| e["id"] }
  end

  def resource_key
    @resource_key ||= begin
      keys = json.keys - ["meta"]
      keys.one? ? keys.first : raise(MultipleRootError)
    end
  end

  alias_method :collection_key, :resource_key
end

ActionController::TestResponse.send(:include, ResponseHelpers)
ActionDispatch::TestResponse.send(:include, ResponseHelpers)
