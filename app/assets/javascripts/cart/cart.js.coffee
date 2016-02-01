$ ->
  return unless $(".cart_item, #product-search-table").length
  selector = $('.cart_item')

  window.CartNotificationDuration = 2000

  class CartItem
    constructor: (opts)->
      {@data, @el} = opts
      @timer = null
      @setElement(@el)

    @buildWithElement: (el)->
      new CartItem
        data: $(el).data("cart-item")
        el: $(el)

    setElement: (el) ->
      @el = el
      $(@el).find(".quantity input.cart-input").keyup ->
        window.clearTimeout(@timer)

        @timer = window.setTimeout =>
          $(this).trigger("cart.inputFinished")
        , 250

    update: (data, silent) ->
      msg = ""

      if (silent != true)

        if (this.data.quantity == 0) && (data.quantity > 0)
          msg = "Added to cart!"

        else if (this.data.quantity > 0) && (data.quantity == 0)
          msg = "Removed from cart!"

          
        else if (this.data.quantity > 0) && (data.quantity > 0)
          msg = "Quantity updated!"

      CartLink.deferredUpdateMessage(msg)

      @data = data
      @updateView()
      @showUpdate()

    updateView: ->
      if @el?

        totalPrice = accounting.formatMoney(@data.total_price)

        @el.find(".price-for-quantity").text(accounting.formatMoney(@data.unit_sale_price))
        @el.find(".price").text(totalPrice)
        @el.find(".quantity input:not(.redesigned)").val(@data.quantity)

        if @el.find(".quantity input").hasClass("promo")
          $(".promo").val(@data.quantity)
          $(".promo").parent().parent().find(".price").text(totalPrice)

        if @data.quantity
          @el.find(".icon-clear").removeClass("is-hidden")
          $(".promo").parent().parent().find(".icon-clear").removeClass("is-hidden")

        if (!@data["valid?"] && @data["id"] != null) && !@data["destroyed?"]
          @showError()
        else
          @clearError()

    remove: ->
      if @el?
        tbody_ref = @el.parent()
        supplier = @el[0].getAttribute("supplier")
        num = tbody_ref.find("[supplier="+supplier+"]").length
        if (num == 2)
          tbody_ref.find(".seller").addClass("is-hidden")
        # if this is the last one, remove all and redirect to products page
        if (tbody_ref.find(".is-hidden").length == tbody_ref.length)
          location.reload(false)
      @el.find(".icon-clear").addClass("is-hidden")

      @showUpdate()
      unless @el.hasClass("product-row") || @el.data("keep-when-zero")
        @el.remove()

      if @el.find(".quantity input").hasClass("promo")
        $(".promo").parent().parent().find(".icon-clear").addClass("is-hidden")
        $(".promo").parent().parent().find(".quantity input").val('')

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
      $(".promo").parent().parent().find(".updated").removeClass("updated")


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

          msg = counter.data('message')
          if msg
            CartLink.showMessage(msg)
            counter.data('message', '')

          if count > 0
            $("#checkout-button").show();
            $('#review_cart').removeClass('is-hidden')
          else
            $("#checkout-button").hide();
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

    updateOrAddItem: (data, element, silent, newElement)->
      item = @itemAt(data.product_id)

      if item?
        item.update(data, silent)
        if newElement?
          item.setElement(element)

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

            window.lo.ProductActions.updateProduct(data.item.product_id, data.item.quantity, data.item.formatted_total_price)
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
    url: $(".cart_items").data("cart-url")
    view: view
    items: $(".cart_item")

  setupAlternateOrderPage = () ->
    return if $("#product-order-search").length == 0

    setupProductSearch()


  setupProductSearch = ->
    products = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: {
        url: "/products/search?q=%QUERY&#{window.location.search.replace('?', '')}",
        wildcard: '%QUERY',
        transform: (response) ->
          response.products
      }
    })

    searchBox = $("#product-order-search")

    searchBox.typeahead({hint: false}, {
      name: 'products',
      display: 'name',
      source: products,
      limit: 101,
      templates: {
        suggestion: (data) ->
          "
            <div class='tt-suggestion column--full clearfix text-div'>
              <div class='heading-row metadata-column-full text-div'>
                <span class='product-name'><strong>#{data.name}</strong></span>
                <span class='unit'>(#{data.unit_with_description})</span>
              </div>
              <div class='metadata-column-half pull-left text-div'>
                <span class='metadata-label'>Category:</span>
                <span class='metadata-text'>#{data.second_level_category_name}</span>
              </div>
              <div class='metadata-column-half pull-left text-div'>
                <span class='metadata-label'>Supplier:</span>
                <span class='metadata-text'>#{data.seller_name}</span>
              </div>
              <div class='metadata-column-full text-div'>
                <span class='metadata-label'>Price:</span>
                <span class='metadata-text'>#{data.pricing}</span>
              </div>
            </div>
          "
        empty: (data) ->
          if data.query.length <= 3
            message = 'Please enter a search term at least four characters long.'
          else
            message = 'No matches were found for this search.'
          "<div style='padding-left:10px;'><p><strong>#{message}</srong></p></div>"
      }
    });

  fetchRenderedRow = (id) ->
    $.getJSON("/products/#{id}/row")

  window.insertCartItemEntry = (el) ->
      model.updateOrAddItem el.data("cart-item"), el, true, true


  view.updateCounter()
  setupAlternateOrderPage()

  $(document.body).on 'cart.inputFinished', ".cart_item .quantity input", ->
    data = $(this).closest(".cart_item").data("cart-item")

    if this.value.length > 0 && !$(this).hasClass('invalid-input')
      quantity = parseInt($(this).val())
      model.saveItem(data.product_id, quantity, this)

    if this.value.length == 0 && !$(this).hasClass("in-cart")
      model.saveItem(data.product_id, 0, this)

  $(document.body).on 'click', ".cart_item .icon-clear", (e)->
    e.preventDefault()
    data = $(this).closest(".cart_item").data("cart-item")
    model.saveItem(data.product_id, 0)

  $(document.body).on 'click', "input[type=radio]", (e)->
    $(".payment-fields").addClass("is-hidden")
    $paymentFields = $(this).parents(".field").find(".payment-fields")
    $paymentFields.removeClass("is-hidden")

    buttonState = !$paymentFields.data('available') == true
    $("#place-order-button").attr("disabled", buttonState)

  $(document.body).on 'keyup', "#provider_card_number", (e) ->
    if $(this).val() != ''
      $("#place-order-button").attr("disabled", false)
    else
      $("#place-order-button").attr("disabled", true)

  $(document.body).on 'click', "#place-order-button", (e)->
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

  $(document.body).on 'click', "#apply-discount", (e)->
    e.preventDefault()
    if $("#discount_code").val() != $("#prev_discount_code").val()
      $(this).parents('form').submit()

  $(document.body).on 'click', "#clear-discount", (e)->
    e.preventDefault()
    if $("#discount_code").val() != ""
      $("#discount_code").val("")
      $(this).parents('form').submit()

  numItems = $('.payment-method').length
  if (numItems == 1)
    $('.payment-method').click()

  if ($('#order_credit_card_id option').size() == 2)
    $('#order_credit_card_id option:last').attr("selected","selected");

