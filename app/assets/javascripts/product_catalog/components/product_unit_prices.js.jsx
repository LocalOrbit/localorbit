(function() {

  var ProductUnitPrices = React.createClass({
    mixins: [window.lo.ProductInputMixin],

    fullPricingRow: function(prices, showCaret) {
      var priceCells = [];
      var priceDisplay, qtyDisplay;
      var caret = (showCaret) ? (<i onClick={this.toggleView} style={{cursor: "pointer"}} className="caretted"/>) : "";
      for(var i = 0; i < 3; i++) {
        if(prices[i]) {
            if (prices[i].organization_id)
                priceDisplay=(<span style={{ color: "#3E8212", fontWeight: "bold" }}>{prices[i].sale_price}{caret}&nbsp;<span className="tooltip tooltip--naked tooltip--notice" data-tooltip="This is a negotiated price specific to you!"><i className="fa fa-question-circle"></i></span></span>);
            else
                priceDisplay=(<span>{prices[i].sale_price}{caret}</span>);

            if (prices[i].min_quantity == 1)
                qtyDisplay = (<span style={{fontSize:"11px", color:"#737373"}}>&nbsp;</span>)
            else
                qtyDisplay = (<span style={{fontSize:"11px", color:"#737373"}}>Min. {prices[i].min_quantity}</span>);

        priceCells.unshift(
            <td style={{textAlign: "right"}}>
              {priceDisplay}<br/>
              {qtyDisplay}
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

    render: function() {
      var pricing = (this.props.product.prices.length <= 3 || this.state.showAll) ? this.fullPricing() : this.abbreviatedPricing();
      var quantity = this.props.product.max_available < 500000 ? this.props.product.max_available + " Available" : "";
      var deleteButton = this.state.cartItemQuantity > 0 ? (<a href="javascript:void(0)" onClick={this.deleteQuantity} className="font-icon icon-clear" style={{marginLeft: "15px"}}></a>) : null;

      return (
        <tr className="cart_item" data-keep-when-zero="yes" data-cart-item={JSON.stringify(this.props.product.cart_item)}>
          <th>
            <a href={"/products/" + this.props.product.id}>{this.props.product.unit_description}</a><br/>
            <span style={{fontSize:"11px", color:"#737373"}}>{quantity}&nbsp;</span>
          </th>
          <td>
            <table>
              {pricing}
            </table>
          </td>
          <td colSpan="2">
            <div style={{float:"left", background:"#F7F7F7", width:"100%", minWidth: "200px", borderRadius: "4px", border:"1px solid #D1D1D1", padding: "4px 0"}}>
              <div className="quantity" style={{float:"left", width:"50%", textAlign:"center"}}>
                <input style={{width: "75px"}} type="number" placeholder="0" value={this.state.cartItemQuantity} className="redesigned app-product-input" onKeyDown={this.updateQuantity}/>
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
