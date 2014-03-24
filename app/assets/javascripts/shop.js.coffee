$ ->
  $("#change-delivery-date").click (e)->
    if $("header .cart .counter").text() == "0"
      $('.change-delivery-warning').remove()
    else
      $('.overlay').addClass('is-dark');
      e.preventDefault()
