$ ->
  return unless $(".cart_item").length
  selector = $('.cart_item')

  window.CartNotificationDuration = 2000

  class CartItem
    constructor: (opts)->
      {@data, @el} = opts
      @timer = null


      $(opts.el).find(".quantity input").keyup ->
        window.clearTimeout(@timer)

        @timer = window.setTimeout =>
          $(this).trigger("cart.inputFinished")
        , 250

    @buildWithElement: (el)->
      new CartItem
        data: $(el).data("cart-item")
        el: $(el)

    update: (data)->
      if (this.data.quantity == 0) && (data.quantity > 0)
        CartLink.showMessage("Added to cart!")

      if (this.data.quantity > 0) && (data.quantity == 0)
        CartLink.showMessage("Removed from cart!")

      if (this.data.quantity > 0) && (data.quantity > 0)
        CartLink.showMessage("Quantity updated!")

      @data = data
      @updateView()
      @showUpdate()

    updateView: ->
      if @el?
        @el.find(".price-for-quantity").text(accounting.formatMoney(@data.unit_sale_price))
        @el.find(".price").text(accounting.formatMoney(@data.total_price))
        @el.find(".quantity input").val(@data.quantity)
        if @data.quantity
          @el.find(".icon-clear").removeClass("is-hidden")

        if !@data["valid?"] && !@data["destroyed?"]
          @showError()
        else
          @clearError()

    remove: ->
      @el.find(".icon-clear").addClass("is-hidden")
      @showUpdate()
      unless @el.hasClass("product-row")
        @el.remove()

    showError: ->
      @el.find(".quantity").addClass("field_with_errors")

    clearError: ->
      @el.find(".quantity").removeClass("field_with_errors")

    showUpdate: ->
      @el.find(".quantity").addClass("updated")
      window.setTimeout =>
        @el.find(".quantity").addClass("finished")
      , window.CartNotificationDuration

      window.setTimeout =>
        @el.find(".quantity").removeClass("updated").removeClass("finished")
      , (window.CartNotificationDuration + 200)


  class CartView
    constructor: (opts)->
      {@counter} = opts

    #actions
    updateCounter: ->
      counter = @counter
      $.getJSON("/cart", {},
        (res) ->
          count = res.total
          counter.attr("data-count", count.toString())
          counter.find(".counter").text(count.toString())
          counter.data('count', count)
          if count > 0
            $('#review_cart').removeClass('is-hidden')
          else
            $('#review_cart').addClass('is-hidden')
      )

    updateSubtotal: (subtotal)->
      totals = $("#totals")
      totals.find(".subtotal").text(accounting.formatMoney(subtotal))

    updateDiscount: (discount) ->
      $discount = $("#totals .discount")
      if discount != undefined
        $discount.parent("tr").removeClass("is-hidden")
        $discount.text(discount)
      else
        $discount.parent("tr").addClass("is-hidden")

    updateDiscountStatus: (status) ->
      $status = $(".discount-field strong")
      if status != undefined && status != null
        $status.text(status)

    updateDeliveryFees: (fees) ->
      totals = $("#totals")
      totals.find(".delivery_fees").text(fees)

    updateTotal: (total) ->
      totals = $("#totals")
      totals.find(".total").text(total)

    showMessage: (info, el)->
      if el.length
        $(el).next('.message').remove()
        $(info).insertAfter(el)

    showErrorMessage: (error, el)->
      @removeErrorMessage(el)

      notice = $("<tr>").addClass("warning").append($("<td>").addClass('flash--warning').attr('colspan', '6').text(error))
      $(notice).insertAfter(el)

    removeErrorMessage: (el)->
      parent = $(el).parents("tr")
      siblings = parent.siblings(".warning")
      siblings.each ->
        $(this).remove()

  class CartModel
    constructor: (opts)->
      {@url, @view} = opts

      @items = _.map opts.items, (el)->
        CartItem.buildWithElement(el)

    itemAt: (id)->
      _.find @items, (item)->
        item.data.product_id == id

    updateOrAddItem: (data, element)->
      item = @itemAt(data.product_id)

      if item?
        item.update(data)

      else
        item = new CartItem(data: data, el: element)
        item.updateView()
        @items.push(item)

      return item

    removeItem: (data)->
      item = @itemAt(data.product_id)
      item.update(data)

      item.data.id = null
      item.remove()

    subtotal: ()->
      _.reduce(@items, (memo, item)->
        memo += parseFloat(item.data.total_price)
      , 0)

    itemCount: ()->
      filteredItems = _.filter @items, (item)->
        item.data.id?

      filteredItems.length

    updateTotals: (data) ->
      @view.updateCounter()
      @view.updateSubtotal(@subtotal())
      @view.updateDiscount(data.discount)
      @view.updateDiscountStatus(data.discount_status)
      @view.updateDeliveryFees(data.delivery_fees)
      @view.updateTotal(data.total)

    saveItem: (productId, quantity, elToUpdate)->
      # TODO: Add validation for maximum input to prevent
      #       users from entering numbers greater than available
      #       quantities

      @view.removeErrorMessage($(elToUpdate))
      if _.isNaN(quantity)
        errorMessage = "Quantity is not a number"
        @view.showErrorMessage(errorMessage, $(elToUpdate).closest('.product'))
        $(elToUpdate).closest(".quantity").addClass("field_with_errors")
      else if quantity < 0
        errorMessage = "Quantity must be greater than or equal to 0"
        @view.showErrorMessage(errorMessage, $(elToUpdate).closest('.product'))
        $(elToUpdate).closest(".quantity").addClass("field_with_errors")
      else
        $.post(@url, {"_method": "put", product_id: productId, quantity: quantity} )
          .done (data)=>

            error = data.error

            if data.item["destroyed?"]
              @removeItem(data.item)
            else
              @updateOrAddItem(data.item)

            @updateTotals(data)

            if error
              @view.showErrorMessage(error, $(elToUpdate).closest('.product'))
            else
              @view.showMessage($('<p class="message">Finished with this product? <a href="/products">Continue Shopping</a></p>'), $(elToUpdate).closest('.product-table--mini'))

  view = new CartView
    counter: $("header a.cart")

  model = new CartModel
    url: selector.closest(".cart_items").data("cart-url")
    view: view
    items: $(".cart_item")


  view.updateCounter()

  $(".cart_item .quantity input").on 'cart.inputFinished', ->
    data = $(this).closest(".cart_item").data("cart-item")

    if this.value.length > 0
      quantity = parseInt($(this).val())
      model.saveItem(data.product_id, quantity, this)

  $(".cart_item .icon-clear").click (e)->
    e.preventDefault()
    data = $(this).closest(".cart_item").data("cart-item")
    model.saveItem(data.product_id, 0)

  $("input[type=radio]").click (e)->
    $(".payment-fields").addClass("is-hidden")
    $paymentFields = $(this).parents(".field").find(".payment-fields")
    $paymentFields.removeClass("is-hidden")

    buttonState = !$paymentFields.data('available') == true
    $("#place-order-button").attr("disabled", buttonState)

  $("#provider_card_number").keyup (e) ->
    if $(this).val() != ''
      $("#place-order-button").attr("disabled", false)
    else
      $("#place-order-button").attr("disabled", true)

  $("#place-order-button").click (e)->
    e.preventDefault()
    $(this).prop("disabled", true)

    $("#payment-provider-errors").html("")
    $(".field_with_errors :input").unwrap()

    isSubmittingUnsavedCreditCard = ()->
      $("#order_payment_method_credit_card").is(":checked") && ($("#order_credit_card_id").val() == '' || $("#order_credit_card_id").val() == undefined)

    if isSubmittingUnsavedCreditCard()
      $(".quantity input").prop("readonly", true)

      newCard = {
        card_number: $("#provider_card_number").val(),
        expiration_month: $("#expiration_month").val(),
        expiration_year: $("#expiration_year").val(),
        security_code: $("#provider_security_code").val()
      }

      $container = $("#payment-provider-container")
      $form = $("#order-form")
      tokenizer = new PaymentSourceTokenizer($form, $container, (key) -> "order[credit_card][#{key}]")
      tokenizer.tokenize(newCard, "card")
        .done (addParam) ->
          # success - update custom params before auto-submit
          accountFields =
            name: $("#provider_account_name").val(),
            save_for_future: "true" # $("#save_for_future").is(":checked")
          addParam key, accountFields[key] for key, field of accountFields
          $container.prop("disabled", true)
        .fail ->
          # failure
          $("#place-order-button").prop("disabled", false)

    else

      $(".quantity input").prop("readonly", true)
      $("#order-form").submit()

  $("#apply-discount").click (e)->
    e.preventDefault()
    if $("#discount_code").val() != $("#prev_discount_code").val()
      $(this).parents('form').submit()

  $("#clear-discount").click (e)->
    e.preventDefault()
    if $("#discount_code").val() != ""
      $("#discount_code").val("")
      $(this).parents('form').submit()
