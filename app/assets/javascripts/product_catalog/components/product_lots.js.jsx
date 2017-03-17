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
        var sale_entry;
        var net_entry;
        var status;
        var build_committed;
        var committed_detail;
        var committed_summary;
        var committed_count;
        var lot;

        if (this.props.salesOrder) {
            if (this.props.orderId) {
                sale_entry = (
                    <input className="redesigned app-sale-price-input" style={{width: "75px"}} type="number"
                           placeholder="0" name="items_to_add[][sale_price]"
                           defaultValue={this.state.cartSalePrice} onKeyDown={this.clearField}/>
                );
                net_entry = (
                    <input className="redesigned app-net-price-input" style={{width: "75px"}} type="number"
                           placeholder="0" name="items_to_add[][net_price]"
                           defaultValue={this.state.cartNetPrice} onKeyDown={this.clearField}/>
                );
            }
            else {
                sale_entry = (
                    <input className=" redesigned app-sale-price-input" style={{width: "75px"}} type="number"
                           placeholder="0"
                           defaultValue={this.state.cartSalePrice} onKeyDown={this.clearField}/>
                );
                net_entry = (
                    <input className="redesigned app-net-price-input" style={{width: "75px"}} type="number"
                           placeholder="0"
                           defaultValue={this.state.cartNetPrice} onKeyDown={this.clearField}/>
                );
            }
        }

        if (this.props.lot.status == 'available' && this.props.lot.quantity > 0) {
            lot_desc = (<div>{this.props.lot.number} / {this.props.lot.quantity}<br/><div style={{fontSize: '12px', color: '#999'}}>{this.props.lot.delivery_date}</div></div>);
            status = (<div style={{fontSize: "11px"}}>On Hand</div>);
        }
        else if (this.props.lot.status == 'awaiting_delivery' && this.props.lot.quantity > 0) {
            lot_desc = (<div>{this.props.lot.quantity}</div>);
            status = (<div style={{fontSize: "11px", color: "#991111"}}>Awaiting Delivery</div>);
        }

        lot = this.props.lot;
        build_committed = '<table class="committed-table"> <thead> <th></th> <th>Sale</th> <th>Net</th> <th>Qty</th> </thead> <tbody>';
        committed_count = 0;
        _.map(this.props.product.committed, function (c) {
                if (lot.number === c.number) {
                    committed_count = committed_count + (c.quantity * 1);
                    build_committed = build_committed +  '<tr> <td>' + c.buyer_name+'</td> <td>' + c.sale_price + '</td> <td>' + c.net_price + '</td> <td>' + c.quantity + '</td> </tr>';
                }
            });

        build_committed = build_committed + '</tbody></table>';

        if (committed_count > 0) {
            committed_detail = build_committed;
            committed_summary = <div style={{marginTop: "10px", fontSize: "10px"}}>{committed_count} Committed</div>
        }
        else {
            committed_detail = ('');
            committed_summary = ('');
        }

      var deleteButton = this.state.cartItemQuantity > 0 ? (<a href="javascript:void(0)" onClick={this.deleteQuantity} className="font-icon icon-clear" style={{marginLeft: "10px"}}></a>) : null;
      var inputClass = "redesigned app-product-input";

      if (this.props.orderId) {
          qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity} name="items_to_add[][quantity]" className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity} />);
          pid = (<input type="hidden" name="items_to_add[][product_id]" value={this.props.product.id}/>);
      }
      else
          qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity} className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity}/>);

      return (
        <tr className="cart_item" data-keep-when-zero="yes" data-cart-item={JSON.stringify(this.props.product.cart_item)}>
          <th style={{verticalAlign: 'top'}}>
            {lot_desc}
            {status}
            {committed_summary}
          </th>
          <td colSpan="4" style={{verticalAlign: 'top'}}>
            <div style={{float:"right", background:"#F7F7F7", width:"100%", borderRadius: "4px", border:"1px solid #D1D1D1", padding: "4px 0"}}>
                <div className="sale_price" style={{float:"left", width:"32%", textAlign:"center"}}>
                  {sale_entry}
                </div>
                <div className="net_price" style={{float:"left", width:"33%", textAlign:"center"}}>
                  {net_entry}
                </div>
                <div className="quantity" style={{float:"left", width:"33%", textAlign:"center"}}>
                    {qty}
                    {pid}
                </div>
                <div style={{float:"left", width:"2%", textAlign:"center", padding: "10px 0"}}>
                    {deleteButton}
                </div>
                <input type="hidden" className="lot_id" defaultValue={this.props.lot.id} />
            </div>
            <div dangerouslySetInnerHTML={{__html: committed_detail }}></div>
          </td>
          </tr>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductLots = ProductLots;
}).call(this);
