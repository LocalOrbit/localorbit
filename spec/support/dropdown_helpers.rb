module DropdownHelpers
  def select_option_on_singleselect(selector, option_text)
    elem = find(selector)
    elem.click
    elem.find('.chosen-drop .chosen-results .active-result', text: option_text).click
  end

  def select_option_on_multiselect(parent_selector, option_text)
    elem = find(parent_selector)
    open_multiselect(elem)
    elem.find('.fs-option:not(.selected) .fs-option-label', text: option_text).click
    close_multiselect(elem)
  end

  def unselect_option_on_multiselect(parent_selector, option_text)
    elem = find(parent_selector)
    open_multiselect(elem)
    elem.find('.fs-option.selected .fs-option-label', text: option_text).click
    close_multiselect(elem)
  end

  private

  def open_multiselect(elem)
    elem.find('.fs-label').click if multiselect_hidden?(elem)
  end

  def close_multiselect(elem)
    elem.find('.fs-label').click unless multiselect_hidden?(elem)
  end

  def multiselect_hidden?(elem)
    elem.find('.fs-wrap .fs-dropdown', visible: :all)[:class].include?("hidden")
  end
end

