class DeleteLocations
  include Interactor

  def perform
    require_in_context(:organization, :location_ids)

    context[:locations] = organization.locations.where(id: location_ids).each { |loc| loc.soft_delete }
  end
end
