class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def name_and_address
    h.capture do
      concat content_tag(:span, name)
      concat "#{address}, #{city}, #{state} #{zip}"
    end
  end
end
