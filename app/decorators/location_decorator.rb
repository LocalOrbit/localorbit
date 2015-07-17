class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def name_and_address
    h.capture do
      concat link_to(name, edit_admin_organization_location_path(organization, location))
      concat "<br> #{address}, #{city}, #{state} #{zip} #{country}".html_safe
    end
  end
end
