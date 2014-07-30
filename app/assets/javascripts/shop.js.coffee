$ ->
  $("#change-delivery-date").click (e)->
    if $("header .cart .counter").text() == "0"
      $('#change-delivery-warning').remove()
      window.location = "/sessions/deliveries/reset?redirect_back_to=%2Fproducts"
    else
      $('.overlay').addClass('is-dark');
      e.preventDefault()
