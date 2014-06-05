showOrHideCategoriesBeyondDepth = (depth) ->
  $('tr').each ->
    row = $(this)
    row_depth = 0 + row.data('depth')
    value = 0 +
    if row_depth > depth
      row.hide()
    else
      row.show()

$ ->
  if $('#filter-categories').length
    showOrHideCategoriesBeyondDepth($('#filter-categories').val())
    $(document).on "change", "#filter-categories", (event) ->
      event.stopPropagation()
      showOrHideCategoriesBeyondDepth($(event.target).val())