$ ->
  $("input.check-all").change ->
    $("input[name='location_ids[]']").prop("checked", $(this).prop("checked"))

  $("#save-update-defaults").click (e) ->
    e.preventDefault()

    link = $(this)

    method = $("input[name='_method']")
    method.prop("value", "put")

    form = link.parent("form")
    form.prop("action", link.prop("href"))
    form.submit()
