$ ->
  if $('table.sortable').length
    options = {}
    if $('table.sortable td:first-child :checkbox').length
      options = headers: {0: {sorter: false}}
    $('table.sortable').tablesorter(options);
