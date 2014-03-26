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
          @el.find(".quantity input").val(@data.quantity)
        if @data["valid?"]
          @el.find(".quantity").removeClass("field_with_errors")
        else
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

    showError: (error)->
      notice = $("<div>").addClass("flash").addClass("flash--alert").append($("<p>").text(error))
      $("#flash-messages").append(notice)
      # TODO: Not sure how to re-create fading out
      # as per fading.js.coffee
      window.setTimeout ->
        notice.fadeOut(500)
      , 3000

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

    updateOrAddItem: (data)->
      item = @itemAt(data.id)

      if item?
        item.update(data)

      else
        # TODO: This will need an element even f it's on the
        # products listing page
        item = new CartItem(data: data)
        @items.push(item)

      return item

    subtotal: ()->
      _.reduce(@items, (memo, item)->
        memo += parseFloat(item.data.total_price)
      , 0)

    saveItem: (productId, quantity)->
      # TODO: Add validation for maximum input to prevent
      #       users from entering numbers greater than available
      #       quantities
      $.post(@url, {"_method": "put", product_id: productId, quantity: quantity} )
        .done (data)=>
          error = data.error
          item = @updateOrAddItem(data.item)

          @view.updateCounter(@items.length)
          @view.updateSubtotal(@subtotal())
          @view.updateDeliveryFees(data.delivery_fees)
          @view.updateTotal(data.total)

          if error
            @view.showError(error)

  view = new CartView
    counter: $("header .cart .counter")

  model = new CartModel
    url: selector.closest(".cart_items").data("cart-url")
    view: view
    items: $(".cart_item")


  $(".cart_item .quantity input").change ->
    data = $(this).closest(".cart_item").data("cart-item")
    quantity = $(this).val()
    model.saveItem(data.product_id, quantity)
