$ ->
  $("#print-button").click (event) ->
    event.preventDefault()
    window.print()

  $("#print-and-mark-invoiced").click (event) ->
    event.preventDefault()

    href = $(this).attr('href')
    $.get href, (response) ->
      window.print()

  $("#print-invoice").click (event) ->
    event.preventDefault()
    window.print()
