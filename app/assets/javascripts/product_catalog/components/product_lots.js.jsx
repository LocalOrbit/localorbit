(function() {

  var ProductLots = React.createClass({
    propTypes: {
        purchaseOrder: React.PropTypes.bool,
        salesOrder: React.PropTypes.bool
    },

    mixins: [window.lo.ProductInputMixin],

    render: function() {
      var qty;
      var pid = ('');
      var lot_desc;
      var sales_entry;
      var net_entry;
      var sales_entry_class;
      var net_entry_class;
      var quantity_class;
      var price_class;

      if (this.props.salesOrder) {
          sales_entry = (
              <input className=" redesigned app-sales-price-input" style={{width: "75px"}} type="number" placeholder="0"
                     defaultValue={this.state.cartItemQuantity} onKeyDown={this.clearField} onChange={this.updateQuantity}/>
          );
          net_entry = (
              <input className="redesigned app-net-price-input" style={{width: "75px"}} type="number" placeholder="0"
                     defaultValue={this.state.cartItemQuantity} onKeyDown={this.clearField} onChange={this.updateQuantity}/>
          );
      }

      lot_desc = (<span>{this.props.lot.number} / {this.props.lot.quantity}</span>);

      var quantity = this.props.product.max_available < 500000 ? this.props.product.max_available + " Available" : "";
      var deleteButton = this.state.cartItemQuantity > 0 ? (<a href="javascript:void(0)" onClick={this.deleteQuantity} className="font-icon icon-clear" style={{marginLeft: "10px"}}></a>) : null;
      var inputClass = "redesigned app-product-input";

      if (this.props.orderId) {
          qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity} name="items_to_add[][quantity]" className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity} />);
          pid = (<input type="hidden" name="items_to_add[][product_id]" value={this.props.product.id}/>);
      }
      else
          qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity} className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity}/>);

      sales_entry_class = 'sales_price' + this.props.lot.id;
      net_entry_class = 'net_price' + this.props.lot.id;
      quantity_class= 'qty quantity' + this.props.lot.id;
      price_class = 'price' + this.props.lot.id;

      return (
        <tr className="cart_item" data-keep-when-zero="yes" data-cart-item={JSON.stringify(this.props.product.cart_item)}>
          <th>
            {lot_desc}
          </th>
          <td colSpan="4">
            <div style={{float:"right", background:"#F7F7F7", width:"100%", borderRadius: "4px", border:"1px solid #D1D1D1", padding: "4px 0"}}>
                <div className={sales_entry_class} style={{float:"left", width:"33%", textAlign:"center"}}>
                  {sales_entry}
                </div>
                <div className={net_entry_class} style={{float:"left", width:"32%", textAlign:"center"}}>
                  {net_entry}
                </div>
                <div className={quantity_class} style={{float:"left", width:"33%", textAlign:"center"}}>
                  {qty}
                  {pid}
              </div>
              <div style={{float:"left", width:"2%", textAlign:"center", padding: "10px 0"}}>
                {deleteButton}
              </div>
              <input type="hidden" className="lot_id" defaultValue={this.props.lot.id} />
            </div>
          </td>
        </tr>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductLots = ProductLots;
}).call(this);
