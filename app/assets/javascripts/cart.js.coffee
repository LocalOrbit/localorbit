$ ->
  return unless $(".cart_item").length
  selector = $('.cart_item')

  class CartView
    constructor: (opts)->
      {@counter} = opts

    # selectors

    #actions
    updateCounter: (count)->
      @counter.text(count.toString())

    updateUnitPrice: (cartId, price)->
      cartItem = $("#cart_item_#{cartId}")
      cartItem.find(".unit_price").text(accounting.formatMoney(price))

    updatePrice: (cartId, price, quantity)->
      cartItem = $("#cart_item_#{cartId}")
      cartItem.find(".price").text(accounting.formatMoney(price*quantity))

  class CartModel
    constructor: (opts)->
      {@url, @items, @view, @prices} = opts

    priceForQuantity: (prices, quantity)->
      sorted_prices = _.sortBy prices, (p)->
        parseFloat(p.sale_price)

      if quantity == 0
        return parseFloat(_.last(sorted_prices).sale_price)

      matching_prices = _.filter sorted_prices, (p)->
        p.min_quantity <= quantity

      parseFloat(_.first(matching_prices).sale_price)

    subTotal: ()->
      # How can I get at the prices with only a productId?
      # TODO: Map and reduce

    objectWasAdded: (data, prices)->
      @items[data.id.toString()] = data

      @view.updateCounter(Object.keys(@items).length)

      price = @priceForQuantity(prices, data.quantity)
      @view.updateUnitPrice(data.id, price)
      @view.updatePrice(data.id, price, data.quantity)

    addItem: (productId, prices, quantity)->
      $.post(@url, {"_method": "put", product_id: productId, quantity: quantity} )
        .done (data)=>
          @objectWasAdded(data, prices)

  view = new CartView
    counter: $("header .cart .counter")

  model = new CartModel
    url: selector.closest(".cart_items").data("cart-url")
    view: view
    items: selector.closest(".cart_items").data("cart-items")

  selector.find(".quantity input").change ()->
    productId = $(this).closest(".cart_item").data("id")
    prices = $(this).closest(".cart_item").data("prices")

    model.addItem(productId, prices, $(this).val())
