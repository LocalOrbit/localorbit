(function() {

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
        cart_item: React.PropTypes.object.isRequired
      }).isRequired
    },

    getInitialState: function() {
      return {
        showAll: false,
        cartItemQuantity: this.props.product.cart_item_quantity
      };
    },

    componentDidMount: function() {
      window.insertCartItemEntry($(this.getDOMNode()));
    },

    updateQuantity: function(event) {
      s = event.target.value.replace(/^0+(?=[0-9])/, '');
      setTimeout(500);

      if (s === '') {
          s = '0';
      }
      if (s != '0' && s < this.props.product.min_available) {
        $("#product-"+this.props.product.id).html("Must order more than minimum quantity.");
        s = '0';
      }
      if (s >= this.props.product.min_available) {
        $("#product-"+this.props.product.id).html("");
      }

      this.setState({cartItemQuantity: s});
    },

    deleteQuantity: function() {
      this.setState({cartItemQuantity: 0});
      $(this.getDOMNode()).keyup();
    }
  };

  window.lo = window.lo || {};
  window.lo.ProductInputMixin = ProductInputMixin;
}).call(this);
