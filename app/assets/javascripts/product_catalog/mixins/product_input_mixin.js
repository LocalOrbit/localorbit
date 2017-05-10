(function() {

    var typingTimer;                //timer identifier
    var doneTypingInterval = 1000;  //time in ms, 5 second for example
    var in_str = '';

    var ProductInputMixin = {
    propTypes: {
      product: React.PropTypes.shape({
        id: React.PropTypes.number.isRequired,
        unit: React.PropTypes.string.isRequired,
        unit_description: React.PropTypes.string,
        prices: React.PropTypes.array.isRequired,
        total_price: React.PropTypes.string.isRequired,
        max_available: React.PropTypes.number.isRequired,
        min_available: React.PropTypes.number.isRequired,
        cart_item_quantity: React.PropTypes.number.isRequired,
        cart_item_net_price: React.PropTypes.number,
        cart_item_sale_price: React.PropTypes.number,
        cart_item_lot_id: React.PropTypes.number,
        cart_item: React.PropTypes.object.isRequired
      }).isRequired
    },

    getInitialState: function() {
      return {
        showAll: false,
        cartItemQuantity: this.props.product && this.props.product.cart_item_quantity > 0 ? this.props.product.cart_item_quantity : null,
        cartSalePrice: this.props.product && this.props.product.cart_item_sale_price > 0 ? this.props.product.cart_item_sale_price : null,
        cartNetPrice: this.props.product && this.props.product.cart_item_net_price > 0 ? this.props.product.cart_item_net_price : null,
        cartLotId: this.props.product && this.props.product.cart_item_lot_id > 0 ? this.props.product.cart_item_lot_id : null
      };
    },

    componentDidMount: function() {
      window.insertCartItemEntry($(ReactDOM.findDOMNode(this)));
    },

    resetField: function(prodId, target, context, in_str) {
        $('#product-' + prodId).html('');
        $(target).removeClass('invalid-value');
        $(target).val('');
        context.setState({cartItemQuantity: null});
        //context.setState({cartSalePrice: null});
        //context.setState({cartNetPrice: null});
        //context.setState({cartLotId: null});
        this.cSalePrice = $(target).parent().parent().find('.app-sale-price-input').val();
        this.cNetPrice = $(target).parent().parent().find('.app-net-price-input').val();

        if ((this.cSalePrice > 0 || this.cSalePrice === 0) && (this.cNetPrice > 0 || this.cNetPrice === 0) && this.cItemQuantity > 0)
            $(target).trigger("cart.inputFinished");

        in_str = '';
    },

    clearField: function(event) {
        var prodId = this.props.product.id;
        var context = this;
        var target = event.target;

        if (event.keyCode == 8 || event.keyCode == 46 || (event.keyCode == 48 && target.length == 0)) {
            this.resetField(prodId, target, context, in_str);
        }
    },

    updateSalePrice: function(event) {
        var context = this;
        var in_str = event.target.value;

        context.setState({cartItemSalePrice: in_str});
     },

    updateNetPrice: function(event) {
        var context = this;
        var in_str = event.target.value;

        context.setState({cartItemNetPrice: in_str});
    },

    updateQuantity: function(event) {
        var minAvail = this.props.product.min_available;
        var prodId = this.props.product.id;
        var context = this;
        var target = event.target;
        var in_str = event.target.value;

        clearTimeout(typingTimer);
        $("#product-" + prodId).html("");
        typingTimer = setTimeout(function () {
            if (minAvail > 0 && in_str < minAvail) {
                $("#product-" + prodId).html("Must order more than minimum quantity.");
                $(target).addClass('invalid-value');
                in_str = '';
                $(target).val('');
            }
            else if (!minAvail || (in_str >= minAvail && in_str != context.state.cartItemQuantity)) {
                $("#product-" + prodId).html("");
                $(target).removeClass('invalid-value');
                context.setState({cartItemQuantity: in_str});
                in_str = '';
                $(target).trigger("cart.inputFinished");
            }
        }, doneTypingInterval);
    },

    inputFinished: function(target) {

        if ((this.cSalePrice > 0 || this.cSalePrice === 0) && (this.cNetPrice > 0 || this.cNetPrice === 0) && this.cItemQuantity > 0)
            $(target).trigger("cart.inputFinished");
    },

    updateSOQuantity: function(event) {
        var target = event.target;
        var addedLotId = $(target).parent().parent().find('.lot-id').val();
        this.cSalePrice = $(target).parent().parent().find('.app-sale-price-input').val();
        this.cNetPrice = $(target).parent().parent().find('.app-net-price-input').val();

        var in_str = event.target.value;

        this.setState({cartItemQuantity: in_str});
        this.cItemQuantity = in_str;

        this.setState({cartLotId: addedLotId});
        this.setState({cartNetPrice: this.cNetPrice});
        this.setState({cartSalePrice: this.cSalePrice});


        if ((this.cSalePrice > 0 || this.cSalePrice === 0) && (this.cNetPrice > 0 || this.cNetPrice === 0) && this.cItemQuantity > 0)
            $(target).trigger("cart.inputFinished");
    },

    updateSOSalePrice: function(event) {
        var target = event.target;
        var in_str = event.target.value;
        var addedLotId = $(target).parent().parent().find('.lot-id').val();
        this.cItemQuantity = $(target).parent().parent().find('.app-product-input').val();
        this.cNetPrice = $(target).parent().parent().find('.app-net-price-input').val();

        this.setState({cartSalePrice: in_str});
        this.cSalePrice = in_str;

        this.setState({cartLotId: addedLotId});
        this.setState({cartNetPrice: this.cNetPrice});
        this.setState({cartItemQuantity: this.cItemQuantity});

        if (this.cSalePrice >= 0 && this.cNetPrice >= 0 && this.cItemQuantity > 0)
            $(target).trigger("cart.inputFinished");
    },

    updateSONetPrice: function(event) {
        var target = event.target;
        var in_str = event.target.value;
        var addedLotId = $(target).parent().parent().find('.lot-id').val();
        this.cItemQuantity = $(target).parent().parent().find('.app-product-input').val();
        this.cSalePrice = $(target).parent().parent().find('.app-sale-price-input').val();

        this.setState({cartNetPrice: in_str});
        this.cNetPrice = in_str;

        this.setState({cartLotId: addedLotId});
        this.setState({cartItemQuantity: this.cItemQuantity});
        this.setState({cartSalePrice: this.cSalePrice});

        if ((this.cSalePrice > 0 || this.cSalePrice === 0) && (this.cNetPrice > 0 || this.cNetPrice === 0) && this.cItemQuantity > 0)
            $(target).trigger("cart.inputFinished");
    },

    deleteQuantity: function() {
      var prodId = this.props.product.id;
      $("#product-" + prodId).html("");
        this.setState({cartItemQuantity: null});
      $(this.getDOMNode()).find('input').val('');
      $(this.getDOMNode()).keyup();
    },

    deleteSOFields: function() {
        var prodId = this.props.product.id;
        $("#product-" + prodId).html("");
        this.setState({cartItemQuantity: null});
        this.setState({cartSalePrice: null});
        this.setState({cartNetPrice: null});
        this.setState({cartLotId: null});
        $(this.getDOMNode()).find('input').val('');
        $(this.getDOMNode()).keyup();
    }
  };

  window.lo = window.lo || {};
  window.lo.ProductInputMixin = ProductInputMixin;
}).call(this);
