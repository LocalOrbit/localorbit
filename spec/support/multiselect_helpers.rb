module MultiselectHelpers
  def toggle_multiselect(parent_selector)
    find("#{parent_selector} .fs-label").click
  end

  def select_option_on_multiselect(parent_selector, option_text)
    toggle_multiselect(parent_selector)
    find('.fs-option:not(.selected) .fs-option-label', text: option_text).click
  end

  def unselect_option_on_multiselect(parent_selector, option_text)
    toggle_multiselect(parent_selector)
    find('.fs-option.selected .fs-option-label', text: option_text).click
  end
end
