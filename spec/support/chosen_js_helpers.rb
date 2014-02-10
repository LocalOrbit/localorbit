module ChosenJs
  module Helpers
    def select_from_chosen(item_text, options)
      field = find_field(options[:from], visible: false)
      option_value = page.evaluate_script("$(\"##{field[:id]} option:contains('#{item_text}')\").val()")
      page.execute_script("$('##{field[:id]}').val('#{option_value}')")
    end
  end
end
