$ ->
  if $('table.sortable').length && $('table.sortable tbody tr').length
    $('table.sortable th').click (e) ->
      e.preventDefault()
      column = $(this).data("column")

      params = parseSearchString()
      params["order_by"] = column

      window.location.search = $.param(params)

  parseSearchString = () ->
    list = window.location.search.substr(1).split("&")
    params = {}
    for param in list
      tokens = param.split("=")
      if tokens.length == 2
        params[tokens[0]] = tokens[1]

    params
