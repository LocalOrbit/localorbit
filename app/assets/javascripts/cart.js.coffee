$ ->
  return unless $("#products").length

  $.ajaxSetup
    beforeSend: (xhr)->
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

  class CartView
    constructor: (opts)->
      {@counter} = opts

    # selectors

    #actions
    updateCounter: (count)->
      @counter.text(count.toString())

  class CartModel
    constructor: (opts)->
      {@url, @items, @view} = opts

    objectWasAdded: (data)->
      @items[data.product_id] = data
      @view.updateCounter(Object.keys(@items))

    addItem: (productId, quantity)->
      $.post(@url, {"_method": "put", product_id: productId, quantity: quantity} )
        .done (data)=>
          @objectWasAdded(data)

  view = new CartView
    counter: $("header .cart .counter")

  model = new CartModel
    url: $("#products").data("cart-url")
    view: view
    items: {}

  $(".product .quantity input").change ()->
    console.log "value changed......"
    productId = $(this).closest(".product").data("id")
    model.addItem(productId, $(this).val())
