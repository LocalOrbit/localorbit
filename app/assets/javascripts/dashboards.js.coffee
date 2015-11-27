$ ->
  $("ul.buttonGroup").click(e) ->
    $("li", this)
    .removeClass("selected")
    .filter(e.target)
    .addClass("selected")
