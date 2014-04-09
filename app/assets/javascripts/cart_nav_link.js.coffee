$ ->
  $("a.cart").click (e)->
    itemCount = $(this).data("count")
    unless itemCount > 0
      e.preventDefault()
      $("#empty-cart").removeClass("is-hidden")
      $(".overlay").addClass("is-open")
