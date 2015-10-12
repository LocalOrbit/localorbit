(function() {

  var ProductUnitPrices = React.createClass({
    propTypes: {
      product: React.PropTypes.shape({
        id: React.PropTypes.number.isRequired,
        unit: React.PropTypes.string.isRequired,
        unit_description: React.PropTypes.string,
        prices: React.PropTypes.array.isRequired,
        total_price: React.PropTypes.string.isRequired,
        max_available: React.PropTypes.number.isRequired,
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

    fullPricingRow: function(prices, showCaret) {
      var priceCells = [];
      var caret = (showCaret) ? (<i onClick={this.toggleView} style={{cursor: "pointer"}} className="caretted"/>) : "";
      for(var i = 0; i < 3; i++) {
        if(prices[i]) {
          priceCells.unshift(
            <td style={{textAlign: "right"}}>
              {prices[i].sale_price}{caret}<br/>
              <span style={{fontSize:"11px", color:"#737373"}}>Min. {prices[i].min_quantity}</span>
            </td>
          );
          caret = "";
        }
        else {
          priceCells.unshift(<td></td>);
        }
      }
      return (<tr>{priceCells}</tr>);
    },

    fullPricing: function() {
      var groupedPrices = _.toArray(_.groupBy(this.props.product.prices, function(element, index){
        return Math.floor(index/3);
      }));
      return _.map(groupedPrices, function(priceGroup, index) {
        var showCaret = (index === 0 && groupedPrices.length > 1);
        return this.fullPricingRow(priceGroup, showCaret);
      }.bind(this));
    },

    abbreviatedPricing: function() {
      var prices = this.props.product.prices;
      return (
        <tr>
          <td colSpan="3" style={{textAlign: "right"}}>
            {prices[prices.length - 1].sale_price} - {prices[0].sale_price}
            <i onClick={this.toggleView} style={{cursor: "pointer"}} className="caretted"/><br/>
            <span style={{fontSize:"11px", color:"#737373"}}>&nbsp;</span>
          </td>
        </tr>
      );
    },

    toggleView: function() {
      this.setState({showAll: !this.state.showAll});
    },

    updateQuantity: function(event) {
      s = event.target.value.replace(/^0+(?=[0-9])/, '');
      if (s === '') {
          s = '0';
      }
      this.setState({cartItemQuantity: s});
    },

    deleteQuantity: function() {
      this.setState({cartItemQuantity: 0});
    },

    render: function() {
      var pricing = (this.props.product.prices.length <= 3 || this.state.showAll) ? this.fullPricing() : this.abbreviatedPricing();
      var quantity = this.props.product.max_available < 500000 ? this.props.product.max_available + " Avail." : "";
      var deleteButton = this.state.cartItemQuantity > 0 ? (<a href="javascript:void(0)" onClick={this.deleteQuantity} className="font-icon icon-clear" style={{marginLeft: "15px"}}></a>) : null;

      return (
        <tr className="cart_item" data-keep-when-zero="yes" data-cart-item={JSON.stringify(this.props.product.cart_item)}>
          <th>
            <a href={"/products/" + this.props.product.id}>{this.props.product.unit_description || this.props.product.unit}</a><br/>
            <span style={{fontSize:"11px", color:"#737373"}}>{quantity}&nbsp;</span>
          </th>
          <td>
            <table>
              {pricing}
            </table>
          </td>
          <td colSpan="2">
            <div style={{float:"left", background:"#F7F7F7", width:"100%", borderRadius: "4px", border:"1px solid #D1D1D1", padding: "4px 0"}}>
              <div className="quantity" style={{float:"left", width:"50%", textAlign:"center"}}>
                <input style={{width: "75px"}} type="number" value={this.state.cartItemQuantity} className="redesigned app-product-input" onChange={this.updateQuantity}/>
              </div>
              <div style={{float:"left", width:"50%", textAlign:"center", padding: "10px 0"}}>
                <span className="price">{this.props.product.total_price}</span>
                {deleteButton}
              </div>
            </div>
          </td>
        </tr>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductUnitPrices = ProductUnitPrices;
}).call(this);
