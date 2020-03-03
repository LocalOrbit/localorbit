(function() {

  var ProductUnitPrices = React.createClass({
    propTypes: {
      purchaseOrder: React.PropTypes.bool
    },

    mixins: [window.lo.ProductInputMixin],

    fullPricingRow: function(prices, showCaret) {
      var priceCells = [];
      var priceDisplay, qtyDisplay;
      var caret = (showCaret) ? (<i onClick={this.toggleView} style={{cursor: "pointer"}} className="caretted"/>) : "";
      for(var i = 0; i < 3; i++) {
        if(prices[i]) {
            if (prices[i].organization_id)
                priceDisplay=(<div style={{ color: "#3E8212", fontWeight: "bold" }}>{prices[i].sale_price}{caret}&nbsp;<div className="tooltip tooltip--naked tooltip--notice" data-tooltip="This is a negotiated price specific to you!"><i className="fa fa-question-circle"></i></div></div>);
            else
                priceDisplay=(<div>{prices[i].sale_price}{caret}</div>);

            if (prices[i].min_quantity == 1)
                qtyDisplay = (<div style={{fontSize:"10px", color:"#737373"}}>&nbsp;</div>);
            else
                qtyDisplay = (<div style={{fontSize:"10px", color:"#737373"}}>Min {prices[i].min_quantity}</div>);

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
            <div style={{fontSize:"11px", color:"#737373"}}>&nbsp;</div>
          </td>
        </tr>
      );
    },

    toggleView: function() {
      this.setState({showAll: !this.state.showAll});
    },

    render: function() {
      var qty;
      var pid = ('');
      var unit_desc;
      var pricing;
      var quantity;
      var fee_type = ('');
      var fee_type_val;

      if(this.props.purchaseOrder)
        pricing = '';
      else
        pricing = (this.props.product.prices.length <= 3 || this.state.showAll) ? this.fullPricing() : this.abbreviatedPricing();

      if(this.props.purchaseOrder)
        unit_desc = (this.props.product.unit_description);
      else {
          quantity = this.props.product.max_available < 500000 ? this.props.product.max_available + " Available" : "";
          unit_desc = (
              <div><a href={"/products/" + this.props.product.id}>{this.props.product.unit_description}</a><br/><div
                  style={{fontSize: "11px", color: "#737373"}}>{quantity}</div></div>);
      }
      var deleteButton = this.state.cartItemQuantity > 0 ? (<a href="javascript:void(0)" onClick={this.deleteQuantity} className="font-icon icon-clear" style={{marginLeft: "10px"}}></a>) : null;
      var inputClass = "redesigned app-product-input";
      if (this.props.promo)
        inputClass = "redesigned app-product-input promo";

      fee_type_val = this.props.product.prices[0].fee_type;

      if (this.props.orderId) {
          qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity} name="items_to_add[][quantity]" className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity} />);
          pid = (<input type="hidden" name="items_to_add[][product_id]" value={this.props.product.id}/>);
          fee_type = (<input type="hidden" name="items_to_add[][fee_type]" className="fee-type" value={fee_type_val}/>);
      }
      else {
          qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity}
                        className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity}/>);
          fee_type = (<input type="hidden" className="fee-type" value={fee_type_val}/>);
      }
      return (
        <tr className="cart_item" data-keep-when-zero="yes" data-cart-item={JSON.stringify(this.props.product.cart_item)}>
          <th>
            {unit_desc}
          </th>
          <td>
            <table>
                <tbody>
                    {pricing}
                </tbody>
            </table>
          </td>
          <td colSpan="2">
            <div style={{float:"right", background:"#F7F7F7", width:"100%", minWidth: 200, maxWidth: 200, borderRadius: "4px", border:"1px solid #D1D1D1", padding: "4px 0"}}>
              <div className="quantity" style={{float:"left", width:"50%", textAlign:"center"}}>
                  {qty}
                  {pid}
                  {fee_type}
              </div>
              <div style={{float:"left", width:"50%", textAlign:"center", padding: "10px 0"}}>
                <div className="price" style={{display: (this.props.purchaseOrder) ? "none" : "inherit" }}>{this.props.product.total_price}</div>
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
