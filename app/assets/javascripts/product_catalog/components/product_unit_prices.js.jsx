(function() {

  var ProductUnitPrices = React.createClass({
    propTypes: {
      unit: React.PropTypes.string.isRequired,
      prices: React.PropTypes.array.isRequired,
      cart_item_quantity: React.PropTypes.number.isRequired,
      max_available: React.PropTypes.number.isRequired,
      total_price: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
      return {
        showAll: false,
        cartItemQuantity: this.props.cart_item_quantity
      };
    },

    fullPricingRow: function(prices, showCaret) {
      var priceCells = [];
      var caret = (showCaret) ? (<th><i onClick={this.toggleView} style={{cursor: "pointer"}} className="caretted"/></th>) : "";
      for(var i = 0; i < 3; i++) {
        if(prices[i]) {
          priceCells.unshift(
            <td style={{textAlign: "center"}}>
              {prices[i].sale_price}<br/><span style={{fontSize:"11px", color:"#737373"}}>Min. {prices[i].min_quantity}</span>
            </td>
          );
        }
        else {
          priceCells.unshift(<td></td>);
        }
      }
      return (<tr>{priceCells}{caret}</tr>);
    },

    fullPricing: function() {
      var groupedPrices = _.toArray(_.groupBy(this.props.prices, function(element, index){
        return Math.floor(index/3);
      }));
      return _.map(groupedPrices, function(priceGroup, index) {
        var showCaret = (index === 0 && groupedPrices.length > 1);
        return this.fullPricingRow(priceGroup, showCaret);
      }.bind(this));
    },

    abbreviatedPricing: function() {
      var prices = this.props.prices;
      return (
        <tr>
          <td colSpan="3">
            {prices[prices.length - 1].sale_price} - {prices[0].sale_price}
            <i onClick={this.toggleView} style={{cursor: "pointer"}} className="caretted"/>
          </td>
        </tr>
      );
    },

    toggleView: function() {
      this.setState({showAll: !this.state.showAll});
    },

    updateQuantity: function(event) {
      this.setState({cartItemQuantity: event.target.value});
    },

    render: function() {
      var pricing = (this.props.prices.length <= 3 || this.state.showAll) ? this.fullPricing() : this.abbreviatedPricing();

      return (
        <tr>
          <th>
            {this.props.unit} <br/>
            <span style={{fontSize:"11px", color:"#737373"}}>{this.props.max_available} Avail.</span>
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
                <span className="price">{this.props.total_price}</span>
                <a style={{display: "none"}} className="font-icon icon-clear" href="javascript:void(0);"></a>
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
