def click_header(text)
  # Doing a regular .click was raising 'Elem is not
  # clickable at point (x, y)' with selenium_chrome* drivers
  elem = find(:xpath, "//table[contains(@class, 'sortable')]/thead/tr/th[@data-column='#{text}']")
  execute_script("arguments[0].click()", elem)
end

def click_header_twice(text)
  click_header(text)
  click_header(text)
end
