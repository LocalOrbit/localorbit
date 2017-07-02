//= require product_catalog/mixins/product_input_mixin.js

(function() {

  var MobileProductInput = React.createClass({
    mixins: [window.lo.ProductInputMixin],

    render: function() {
        var qty;
        var pid = ('');
        var fee_type = ('');
        var inputClass = "redesigned app-product-input";
        if (this.props.promo)
            inputClass = "redesigned app-product-input promo";

        if (this.props.orderId) {
            qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity} name="items_to_add[][quantity]" className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity} />);
            pid = (<input type="hidden" name="items_to_add[][product_id]" value={this.props.product.id}/>);
            fee_type = (<input type="hidden" name="items_to_add[][fee_type]" className="fee-type" value={this.props.product.prices[0].fee_type}/>);

        }
        else {
            qty = (
                <input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity}
                       className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity}/>);
            fee_type = (<input type="hidden" className="fee-type" value={this.props.product.prices[0].fee_type}/>);

        }
        var deleteButton = this.state.cartItemQuantity > 0 ? (<a href="javascript:void(0)" onClick={this.deleteQuantity} className="font-icon icon-clear" style={{marginLeft: "10px"}}></a>) : null;

        return (
        <section style={{display: "table", textAlign: "center", width: "100%"}} className="order-table-mobile cart_item" data-cart-item={JSON.stringify(this.props.product.cart_item)} data-keep-when-zero="true">
          <header style={{display: "table-row"}}>
            <div style={{display: "table-cell", width: "50%"}}>ORDER QTY</div>
            <div style={{display: "table-cell", width: "50%"}}>TOTAL COST</div>
          </header>
          <div style={{display: "table-row"}}>
            <div className="quantity" style={{display: "table-cell"}}>
                {qty}
                {pid}
                {fee_type}
                <span style={{display: "block", fontSize: "11px", color: "#999", fontWeight: "600"}}>{this.props.product.unit}</span></div>
            <div style={{display: "table-cell", fontWeight: "600"}}>
               <span className="price">{this.props.product.total_price}</span>
              {deleteButton}
            </div>
          </div>
          <div className="errormsg" id={'product-'+ this.props.product.id} style={{ display: "table-row", fontSize: 10, color:"red"}}></div>
        </section>

        );
    }
  });

  window.lo = window.lo || {};
  window.lo.MobileProductInput = MobileProductInput;
}).call(this);
