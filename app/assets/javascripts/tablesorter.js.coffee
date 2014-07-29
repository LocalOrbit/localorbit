$ ->
  if $('table.sortable').length && $('table.sortable tbody tr').length
    $('table.sortable th').click (e) ->
      e.preventDefault()
      direction = ""
      column = $(this).data("column")


      if column
        if $(this).hasClass("headerSortUp")
          $(this).removeClass("headerSortUp").addClass("headerSortDown")
          direction = "desc"
        else
          $(this).removeClass("headerSortDown").addClass("headerSortUp")
          direction = "asc"

        params = parseSearchString()
        params["sort"] = "#{column}-#{direction}"

        window.location.search = $.param(params)

  parseSearchString = () ->
    list = window.location.search.substr(1).split("&")
    params = {}
    for param in list
      tokens = param.split("=")
      if tokens.length == 2
        params[tokens[0]] = tokens[1]

    params
