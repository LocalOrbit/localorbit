$ ->
  return unless $(".cart_item, #product-search-table").length
  selector = $('.cart_item')
  order_id = $('.add-items-to-order').data('order-id')
  order_min = $('.subtotal').data('order-min')
  subtotal = $('.subtotal').data('subtotal')
  order_type = $('#order_order_type').prop('value')

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

      $(@el).find('.quantity input.cart-input, .net-price input.cart-input, .sale-price input.cart-input').keyup ->
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
          msg = "Item updated!"

      CartLink.deferredUpdateMessage(msg)

      @data = data
      @updateView()
      @showUpdate()

    updateView: ->
      if @el?
        totalPrice = accounting.formatMoney(@data.total_price)

        @el.find(".price-for-quantity").text(accounting.formatMoney(@data.unit_sale_price))
        @el.find('.price').text(totalPrice)
        @el.find('.quantity input:not(.redesigned)').val(@data.quantity)

        if @el.find(".quantity input").hasClass("promo") && @data.quantity > 0
          @el.find(".promo").val(@data.quantity)
          @el.find(".promo").parent().parent().find(".price").text(totalPrice)

        if @data.quantity && @data.quantity > 0
          @el.find(".icon-clear").removeClass("is-hidden")
          @el.parent().parent().parent().parent().parent().parent().parent().find(".promo").parent().parent().find(".icon-clear").removeClass("is-hidden")

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

      if @el.find(".app-product-input input").hasClass("promo")
        totalPrice = accounting.formatMoney(@data.total_price)
        $(".promo").parent().parent().find(".icon-clear").addClass("is-hidden")
        $(".promo").parent().parent().find(".quantity input").val('')
        $(".promo").parent().parent().find(".price").text(totalPrice)

    showError: ->
      @el.find('.app-product-input').addClass("field_with_errors")

    clearError: ->
      @el.find('.app-product-input').removeClass("field_with_errors")

    showUpdate: ->
      @el.find('.app-product-input').addClass("updated")
      window.setTimeout =>
        @el.find('.app-product-input').addClass("finished")
      , window.CartNotificationDuration

      window.setTimeout =>
        @el.find('.app-product-input').removeClass("updated").removeClass("finished")
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
      if subtotal*1 >= order_min*1 || order_type == 'purchase'
        $('.order-min-msg').html('')
        $('.payment-method').prop("disabled", false)
        #$("#place-order-button").prop("disabled", false)
      else if order_min > 0
        $('.order-min-msg').html('<h2 class="order-min-msg" style="float: left; margin-left: 15px; color: red;">Your order does not meet the subtotal order minimum of ' + accounting.formatMoney(order_min) + '</h2>')
        $('.payment-method').prop("disabled", true)
        $('.payment-method').prop("checked", false)
        #$("#place-order-button").prop("disabled", true)

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
      {@url, @orderId, @view} = opts

      @items = _.map opts.items, (el)->
        CartItem.buildWithElement(el)

    itemAt: (id, lot_id)->
      _.find @items, (item)->
        item.data.product_id == id && (item.data.lot_id == lot_id || item.data.lot_id == null)

    updateOrAddItem: (data, element, silent, newElement)->
      item = @itemAt(data.product_id, data.lot_id)

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
      item = @itemAt(data.product_id, data.lot_id)
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

    saveItem: (productId, quantity, netPrice, salePrice, feeType, lotId, ctId, elToUpdate, orderId)->
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
        $.post(@url, {"_method": "put", product_id: productId, quantity: quantity, net_price: netPrice, sale_price: salePrice, fee_type: feeType, order_id: orderId, lot_id: lotId, ct_id: ctId} )
          .done (data)=>

            error = data.error

            window.lo.ProductActions.updateProduct(data.item.product_id, data.item.quantity, data.item.net_price, data.item.sale_price, data.item.fee_type, data.item.formatted_total_price, data.item.lot_id, data.item.ct_id)
            if data.item["destroyed?"]
              @removeItem(data.item)
            else
              @updateOrAddItem(data.item)

            if !order_id
              @updateTotals(data)

            if error
              @view.showErrorMessage(error, $(elToUpdate).closest('.product'))
            else
              @view.showMessage($('<p class="message">Finished with this product? <a href="/products">Continue Shopping</a></p>'), $(elToUpdate).closest('.product-table--mini'))
        .error (data)=>
          @updateOrAddItem(data.item)

  view = new CartView
    counter: $("header a.cart")

  model = new CartModel
    url: $(".cart_items").data("cart-url")
    orderId: order_id
    orderMin: order_min
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

  if !order_id
    view.updateCounter()
    view.updateSubtotal(subtotal)

  setupAlternateOrderPage()

  # Create a Stripe client
  if $("#payment-provider-container").length > 0
    stripe_v3 = Stripe($("#payment-provider-container").data("stripe-publishable-key"))

    # Create an instance of Elements
    elements = stripe_v3.elements()

    # Custom styling can be passed to options when creating an Element.
    # (Note that this demo uses a wider set of styles than the guide below.)
    style =
      base:
        color: '#32325d'
        lineHeight: '24px'
        fontFamily: 'Helvetica Neue'
        fontSmoothing: 'antialiased'
        fontSize: '16px'
        '::placeholder': color: '#aab7c4'
      invalid:
        color: '#fa755a'
        iconColor: '#fa755a'

    # Create an instance of the card Element
    card = elements.create('card', style: style)

    # Add an instance of the card Element into the `card-element` <div>
    card.mount '#card-element'

    # Handle real-time validation errors from the card Element.
    card.addEventListener 'change', (event) ->
      displayError = document.getElementById('card-errors')
      if event.error
        displayError.textContent = event.error.message
      else
        displayError.textContent = ''
      return

  # ---
  # generated by js2coffee 2.2.0
  $(document.body).on 'cart.inputFinished', ".cart_item .quantity input, .cart_item .net-price input, .cart_item .sale-price input", ->
    data = $(this).closest(".cart_item").data("cart-item")

    if this.value.length > 0 && !$(this).hasClass('invalid-input')
      if $(this).hasClass('app-product-input')
        quantity = parseInt($(this).val())
      else
        if $(this).hasClass("in-cart")
          quantity = parseInt($(this).parent().parent().find('.app-product-input').val())
        else
          quantity = parseInt($(this).parent().parent().parent().parent().find('.app-product-input').val())

      if $(this).hasClass("in-cart")
        netPrice = parseFloat($(this).parent().parent().find('.app-net-price-input').val())
      else
        netPrice = parseFloat($(this).parent().parent().parent().parent().find('.app-net-price-input').val())

      if $(this).hasClass("in-cart")
        salePrice = parseFloat($(this).parent().parent().find('.app-sale-price-input').val())
      else
        salePrice = parseFloat($(this).parent().parent().parent().parent().find('.app-sale-price-input').val())

      if $(this).hasClass("in-cart")
        lotId = parseInt($(this).parent().parent().find('.lot-id').val())
      else
        lotId = parseInt($(this).parent().parent().parent().parent().find('.lot-id').val())

      if $(this).hasClass("in-cart")
        ctId = parseInt($(this).parent().parent().find('.ct-id').val())
      else
        ctId = parseInt($(this).parent().parent().parent().parent().find('.ct-id').val())

      if $(this).hasClass("in-cart")
        feeType = parseInt($(this).parent().parent().find('.fee-type').val())
      else
        feeType = parseInt($(this).parent().parent().parent().parent().find('.fee-type').val())

      if netPrice == 'NaN'
        netPrice = 0.0

      if salePrice == 'NaN'
        salePrice = 0.0

      model.saveItem(data.product_id, quantity, netPrice, salePrice, feeType, lotId, ctId, this, order_id)

    if this.value.length == 0 && !$(this).hasClass("in-cart")
      lotId = $(this).parent().parent().find(".lot-id").val()
      ctId = $(this).parent().parent().find(".ct-id").val()
      model.saveItem(data.product_id, 0, 0, 0, 0, lotId, ctId, this, order_id)

  $(document.body).on 'click', ".cart_item .icon-clear", (e)->
    e.preventDefault()
    data = $(this).closest(".cart_item").data("cart-item")
    if $(this).hasClass("in-cart") || $(this).hasClass("consignment")
      lotId = $(this).parent().parent().find(".lot-id").val()
    else
      lotId = $(this).parent().parent().parent().parent().parent().parent().parent().find(".lot-id").val()

    if $(this).hasClass("in-cart") || $(this).hasClass("consignment")
      ctId = $(this).parent().parent().find(".ct-id").val()
    else
      ctId = $(this).parent().parent().parent().parent().parent().parent().parent().find(".ct-id").val()

    if $(this).hasClass("in-cart") || $(this).hasClass("consignment")
      feeType = $(this).parent().parent().find(".fee-type").val()
    else
      feeType = $(this).parent().parent().parent().parent().parent().parent().parent().find(".fee-type").val()

    model.saveItem(data.product_id, 0, 0, 0, 0, lotId, ctId, this, order_id)

  $(document.body).on 'click', "input[type=radio]", (e)->
    $(".payment-fields").addClass("is-hidden")
    $paymentFields = $(this).parents(".field").find(".payment-fields")
    $paymentFields.removeClass("is-hidden")

    buttonState = $("h2.order-min-msg").text().trim().length > 0
    $("#place-order-button").attr("disabled", buttonState)

  toggleNewCreditCard = (e) ->
    if ($("#order_credit_card_id").val() == '' || $("#order_credit_card_id").val() == undefined)
      $("#cc-fields").removeClass("is-hidden")
    else
      $("#cc-fields").addClass("is-hidden")

  $(document.body).on 'change', "#order_credit_card_id", toggleNewCreditCard

  $(document.body).on 'keyup', "#provider_card_number", (e) ->
    if $(this).val() != ''
      $("#place-order-button").attr("disabled", false)
    else
      $("#place-order-button").attr("disabled", true)

  $(document.body).on 'click', ".submit-split", (e)->
    e.preventDefault()
    $(this).attr("disabled", true)
    quantity = $(this).parent().parent().parent().find(".split-qty").val()
    unallocated = $(this).parent().parent().parent().data("unallocated")
    productId = $(this).parent().parent().parent().find(".split-product option:selected").val()
    lotId = $(this).parent().parent().parent().parent().parent().parent().parent().find(".lot-id").val()
    parentProductId = $(this).parent().parent().parent().parent().parent().parent().parent().parent().parent().data("cart-item")["product_id"]
    if quantity > 0 && quantity <= unallocated
      $.post("/admin/products/split", {parent_product_id: parentProductId, product_id: productId, lot_id: lotId, quantity: quantity} )
        .done (data)=>
          location.reload()

  $(document.body).on 'click', ".undo-submit-split", (e)->
    e.preventDefault()
    #$(this).attr("disabled", true)
    productId = $(this).parent().parent().parent().parent().parent().data("cart-item")["product_id"]
    $.post("/admin/products/undo_split", {product_id: productId} )
      .done (data)=>
        location.reload()

  $(document.body).on 'click', "#place-order-button", (e)->
    e.preventDefault()
    $(this).prop("disabled", true)

    $("#payment-provider-errors").html("")
    $(".field_with_errors :input").unwrap()

    isSubmittingUnsavedCreditCard = ()->
      $("#order_payment_method_credit_card").is(":checked") && ($("#order_credit_card_id").val() == '' || $("#order_credit_card_id").val() == undefined)

    if isSubmittingUnsavedCreditCard()
      $(".quantity input").prop("readonly", true)

      stripe_v3.createToken(card).then (result) ->
        if result.error
          # Inform the user if there was an error
          errorElement = document.getElementById('card-errors')
          errorElement.textContent = result.error.message
          console.log result.error.message
          $("#place-order-button").prop("disabled", false)
        else
          # Send the token to your server
          #alert JSON.stringify(result.token)
          #console.log JSON.stringify(result.token)
          # Insert the token ID into the form so it gets submitted to the server
          order_form = document.getElementById('order-form')
          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute 'type', 'hidden'
          hiddenInput.setAttribute 'name', 'order[credit_card][stripe_tok]'
          hiddenInput.setAttribute 'value', result.token.id
          order_form.appendChild hiddenInput

          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute 'type', 'hidden'
          hiddenInput.setAttribute 'name', 'order[credit_card][bank_name]'
          hiddenInput.setAttribute 'value', result.token.card.brand
          order_form.appendChild hiddenInput

          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute 'type', 'hidden'
          hiddenInput.setAttribute 'name', 'order[credit_card][last_four]'
          hiddenInput.setAttribute 'value', result.token.card.last4
          order_form.appendChild hiddenInput

          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute 'type', 'hidden'
          hiddenInput.setAttribute 'name', 'order[credit_card][expiration_month]'
          hiddenInput.setAttribute 'value', result.token.card.exp_month
          order_form.appendChild hiddenInput

          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute 'type', 'hidden'
          hiddenInput.setAttribute 'name', 'order[credit_card][expiration_year]'
          hiddenInput.setAttribute 'value', result.token.card.exp_year
          order_form.appendChild hiddenInput

          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute 'type', 'hidden'
          hiddenInput.setAttribute 'name', 'order[credit_card][account_type]'
          hiddenInput.setAttribute 'value', 'card'
          order_form.appendChild hiddenInput

          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute 'type', 'hidden'
          hiddenInput.setAttribute 'name', 'order[credit_card][save_for_future]'
          hiddenInput.setAttribute 'value', $("#save_for_future").is(":checked")
          order_form.appendChild hiddenInput

          #alert result.token.id
          #alert 'submitting form'

          # Submit the form
          $(".quantity input").prop("readonly", true)
          order_form.submit()
        return

        ###
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
                save_for_future: $("#save_for_future").is(":checked")
              addParam key, accountFields[key] for key, field of accountFields
              $container.prop("disabled", true)
            .fail ->
              # failure
              $("#place-order-button").prop("disabled", false)###
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

  $(document.body).on 'click', "#submit-add-items", (e)->
    e.preventDefault()
    $(this).prop("disabled", true)
    $(this).parents('form').submit()

  numItems = $('.payment-method').length
  if numItems == 1
    $('.payment-method').click()

  if ($('#order_credit_card_id option').size() >= 2)
    $('#order_credit_card_id option:last').attr("selected","selected")
