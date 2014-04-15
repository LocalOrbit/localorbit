$ ->
  $("a.cart").click (e)->
    itemCount = $(this).data("count")
    unless itemCount > 0
      e.preventDefault()
      $("#empty-cart").removeClass("is-hidden")
      $(".overlay").addClass("is-open")


  class CartLink
    constructor: ->
      @timer = null
      @el = $("a.cart")
      @messageContainer = $("<div>").addClass('is-hidden')
      @el.append(@messageContainer)

    showMessage: (message)->
      if @timer
        window.clearTimeout(@timer)

      @messageContainer.text(message)
      @messageContainer.removeClass('is-hidden')

      @timer = setTimeout(@hideMessage, 5000)

    hideMessage: =>
      console.log @messageContainer
      @messageContainer.addClass('is-hidden')
      @messageContainer.text("")

  window.CartLink = new CartLink()
