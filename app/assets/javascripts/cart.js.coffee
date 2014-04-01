$ ->
  return unless $(".cart_item").length
  selector = $('.cart_item')

  class CartItem
    constructor: (opts)->
      {@data, @el} = opts

    @buildWithElement: (el)->
      new CartItem
        data: $(el).data("cart-item")
        el: $(el)

    update: (data)->
      @data = data
      @updateView()

    updateView: ->
      if @el?
        @el.find(".price-for-quantity").text(accounting.formatMoney(@data.unit_sale_price))
        @el.find(".price").text(accounting.formatMoney(@data.total_price))
        if @data.quantity
          @el.find(".icon-clear").removeClass("is-hidden")
          @el.find(".quantity input").val(@data.quantity)
        if @data["valid?"]
          @showError()
        else
          @clearError()

    remove: ->
      @el.find(".icon-clear").addClass("is-hidden")
      unless @el.hasClass("product-row")
        $(@el).remove()

    showError: ->
      @el.find(".quantity").removeClass("field_with_errors")

    clearError: ->
      @el.find(".quantity").addClass("field_with_errors")


  class CartView
    constructor: (opts)->
      {@counter} = opts

    #actions
    updateCounter: (count)->
      @counter.text(count.toString())

    updateSubtotal: (subtotal)->
      totals = $("#totals")
      totals.find(".subtotal").text(accounting.formatMoney(subtotal))

    updateDeliveryFees: (fees) ->
      totals = $("#totals")
      totals.find(".delivery_fees").text(fees)

    updateTotal: (total) ->
      totals = $("#totals")
      totals.find(".total").text(total)

    showErrorMessage: (error)->
      notice = $("<div>").addClass("flash").addClass("flash--alert").append($("<p>").text(error))
      $("#flash-messages").append(notice)
      # TODO: Not sure how to re-create fading out
      # as per fading.js.coffee
      window.setTimeout ->
        notice.fadeOut(500)
      , 3000

    showUpdate: (el)->
      $(el).closest(".quantity").addClass("updated")
      window.setTimeout ->
        $(el).closest(".quantity").addClass("finished")
      , 500

      window.setTimeout ->
        $(el).closest(".quantity").removeClass("updated").removeClass("finished")
      , 700


  class CartModel
    constructor: (opts)->
      {@url, @view} = opts

      itemsOnPage = _.map opts.items, (el)->
        CartItem.buildWithElement(el)

      @items = _.filter itemsOnPage, (item)->
        item.data.id?

    itemAt: (id)->
      _.find @items, (item)->
        item.data.id == id

    updateOrAddItem: (data, element)->
      item = @itemAt(data.id)

      if item?
        item.update(data)

      else
        # TODO: This will need an element even f it's on the
        # products listing page
        item = new CartItem(data: data, el: element)
        item.updateView()
        @items.push(item)

      return item

    removeItem: (data)->
      item = @itemAt(data.id)
      @items = _.without @items, item
      item.remove()

    subtotal: ()->
      _.reduce(@items, (memo, item)->
        memo += parseFloat(item.data.total_price)
      , 0)

    updateTotals: (data) ->
      @view.updateCounter(@items.length)
      @view.updateSubtotal(@subtotal())
      @view.updateDeliveryFees(data.delivery_fees)
      @view.updateTotal(data.total)

    saveItem: (productId, quantity, elToUpdate)->
      # TODO: Add validation for maximum input to prevent
      #       users from entering numbers greater than available
      #       quantities
      if _.isNaN(quantity)
        errorMessage = "Quantity is not a number"
        @view.showErrorMessage(errorMessage)
        $(elToUpdate).closest(".quantity").addClass("field_with_errors")
      else if quantity < 0
        errorMessage = "Quantity must be greater than or equal to 0"
        @view.showErrorMessage(errorMessage)
        $(elToUpdate).closest(".quantity").addClass("field_with_errors")
      else
        $.post(@url, {"_method": "put", product_id: productId, quantity: quantity} )
          .done (data)=>

            error = data.error
            if data.destroyed
              @removeItem(data.item)
            else
              @updateOrAddItem(data.item)

            @updateTotals(data)

            if error
              @view.showErrorMessage(error)
            else
              @view.showUpdate(elToUpdate)

  view = new CartView
    counter: $("header .cart .counter")

  model = new CartModel
    url: selector.closest(".cart_items").data("cart-url")
    view: view
    items: $(".cart_item")


  $(".cart_item .quantity input").change ->
    data = $(this).closest(".cart_item").data("cart-item")
    quantity = parseInt($(this).val())
    model.saveItem(data.product_id, quantity, this)

  $(".cart_item .icon-clear").click (e)->
    e.preventDefault()
    data = $(this).closest(".cart_item").data("cart-item")
    model.saveItem(data.product_id, 0)
