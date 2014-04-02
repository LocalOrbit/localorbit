$ ->
  if $('table.sortable').length && $('table.sortable tbody tr').length
    options = {}
    if $('table.sortable td:first-child :checkbox').length
      options = headers: {0: {sorter: false}}
    $('table.sortable').tablesorter(options);
