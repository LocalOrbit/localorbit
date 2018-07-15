def click_header(text)
  find(:xpath, "//table[contains(@class, 'sortable')]/thead/tr/th[@data-column='#{text}']").click
end

def click_header_twice(text)
  click_header(text)
  click_header(text)
end
