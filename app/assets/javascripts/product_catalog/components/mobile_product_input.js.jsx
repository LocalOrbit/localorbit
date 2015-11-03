//= require product_catalog/mixins/product_input_mixin.js

(function() {

  var MobileProductInput = React.createClass({
    mixins: [window.lo.ProductInputMixin],

    render: function() {
      return (
        <section style={{display: "table", textAlign: "center", width: "100%"}} className="order-table-mobile cart_item" data-cart-item={JSON.stringify(this.props.product.cart_item)} data-keep-when-zero="true">
          <header style={{display: "table-row"}}>
            <div style={{display: "table-cell", width: "50%"}}>ORDER QTY</div>
            <div style={{display: "table-cell", width: "50%"}}>TOTAL COST</div>
          </header>
          <div style={{display: "table-row"}}>
            <div className="quantity" style={{display: "table-cell",}}>
              <input type="number" defaultValue={this.state.cartItemQuantity} onChange={this.updateQuantity} style={{width:  "90px"}}/>
              <span style={{display: "block", fontSize: "11px", color: "#999", fontWeight: "600"}}>{this.props.product.unit}</span></div>
            <div style={{display: "table-cell", fontWeight: "600"}}>
              {this.props.product.total_price} <a href="javascript:void(0)" onClick={this.deleteQuantity} className="font-icon icon-clear"></a>
            </div>
          </div>
        </section>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.MobileProductInput = MobileProductInput;
}).call(this);
