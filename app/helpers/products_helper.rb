module ProductsHelper
  def product_listing_disclaimer
    content_tag(:div, "Your product will not appear in the Shop until all of these actions are complete", class: "alert")
  end

  def us_states
    Country["US"].states.map do |_, state|
      [state["name"], state["name"]]
    end
  end
end
