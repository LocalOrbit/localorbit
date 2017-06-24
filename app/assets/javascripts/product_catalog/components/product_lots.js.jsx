(function() {

  var ProductLots = React.createClass({
    propTypes: {
        purchaseOrder: React.PropTypes.bool,
        salesOrder: React.PropTypes.bool
    },

    mixins: [window.lo.ProductInputMixin],

    componentDidMount: function() {
      $('.quantity').removeClass("updated").removeClass("finished");
    },

    render: function() {
        var qty;
        var pid = ('');
        var lid = ('');
        var cid = ('');
        var lot_desc;
        var sale_entry;
        var net_entry;
        var status;
        var build_committed;
        var build_committed_ad;
        var committed_detail;
        var committed_summary;
        var committed_ad_detail;
        var committed_ad_summary;
        var committed_count;
        var committed_ad_count;
        var lot;
        var split_select_options;
        var split_action;
        var undo_split_action;
        var note_indicator;
        var defaultSale;
        var defaultNet;
        var prd;

        prd = this.props.product;

        if (this.props.salesOrder) {
            if (this.state.cartSalePrice && this.state.cartLotId == this.props.lot.id)
                defaultSale = this.state.cartSalePrice;
            else if (this.props.product.prices.length > 0 && this.props.product.prices[0].sale_price) {
                defaultSale = this.props.product.prices[0].sale_price;
                this.cSalePrice = this.props.product.prices[0].sale_price;
            }
            else
                defaultSale = '';

            if (this.state.cartNetPrice && this.state.cartLotId == this.props.lot.id)
                defaultNet = this.state.cartNetPrice;
            else if (this.props.product.prices.length > 0 && this.props.product.prices[0].net_price) {
                defaultNet = this.props.product.prices[0].net_price;
                this.cNetPrice = this.props.product.prices[0].net_price;
            }
            else
                defaultNet = '';

            if (this.props.orderId) {
                sale_entry = (
                    <input className="redesigned app-sale-price-input" style={{width: "75px"}} type="number"
                           placeholder="0" name="items_to_add[][sale_price]"
                           defaultValue={defaultSale} onKeyDown={this.clearField} onChange={this.updateSOSalePrice}/>
                );
                net_entry = (
                    <input className="redesigned app-net-price-input" style={{width: "75px"}} type="number"
                           placeholder="0" name="items_to_add[][net_price]"
                           defaultValue={defaultNet} onKeyDown={this.clearField} onChange={this.updateSONetPrice}/>
                );
            }
            else {
                sale_entry = (
                    <input className=" redesigned app-sale-price-input" style={{width: "75px"}} type="number"
                           placeholder="0"
                           defaultValue={defaultSale} onKeyDown={this.clearField} onChange={this.updateSOSalePrice}/>
                );
                net_entry = (
                    <input className="redesigned app-net-price-input" style={{width: "75px"}} type="number"
                           placeholder="0"
                           defaultValue={defaultNet} onKeyDown={this.clearField} onChange={this.updateSONetPrice}/>
                );
            }
        }

        if (this.props.lot.inv_note)
            note_indicator = (<div className="tooltip--flag" data-tooltip={this.props.lot.inv_note}></div>);
        else
            note_indicator = ('');

        lot = this.props.lot;
        build_committed = '<table class="committed-table"> <thead> <th></th> <th>Date</th> <th>Qty</th> <th>Sale</th> <th>Net</th> </thead> <tbody>';
        committed_count = 0;
        _.map(this.props.product.committed, function (c) {
            if (lot.number === c.number) {
                committed_count = committed_count + (c.quantity * 1);
                build_committed = build_committed +  '<tr> <td>' + c.buyer_name+'</td> <td>' + c.delivered_at + '</td><td>' + c.quantity + '</td> <td>' + c.sale_price + '</td> <td>' + c.net_price + '</td> </tr>';
            }
        });

        build_committed = build_committed + '</tbody></table>';

        build_committed_ad = '<table class="committed-table"> <thead> <th></th> <th>Date</th> <th>Qty</th> <th>Sale</th> <th>Net</th> </thead> <tbody>';
        committed_ad_count = 0;
        _.map(this.props.product.committed_ad, function (c) {
            if (lot.number === "") {
                committed_ad_count = committed_ad_count + (c.quantity * 1);
                build_committed_ad = build_committed_ad +  '<tr> <td>' + c.buyer_name+'</td> <td>' + c.delivered_at + '</td><td>' + c.quantity + '</td> <td>' + c.sale_price + '</td> <td>' + c.net_price + '</td> </tr>';
            }
        });

        build_committed_ad = build_committed_ad + '</tbody></table>';

        if (this.props.lot.status == 'available' && this.props.lot.quantity >= 0) {
            lot_desc = (<div><div>{note_indicator}</div>{this.props.lot.number} / {this.props.lot.quantity + committed_count}<br/><div style={{fontSize: '12px', color: '#999'}}>{this.props.lot.delivery_date}</div></div>);
            status = (<div style={{fontSize: "11px"}}>On Hand</div>);
        }
        else if (this.props.lot.status == 'awaiting_delivery' && this.props.lot.quantity + committed_ad_count > 0) {
            lot_desc = (<div>{this.props.lot.quantity + committed_ad_count}</div>);
            status = (<div style={{fontSize: "11px", color: "#991111"}}>Awaiting Delivery</div>);
        }

        if (committed_count > 0) {
            committed_detail = build_committed;
            committed_summary = <div style={{marginTop: "10px", fontSize: "10px"}}>{committed_count} Committed</div>
            committed_ad_detail = ('');
            committed_ad_summary = ('');
        }
        else if (committed_ad_count > 0) {
            committed_ad_detail = build_committed_ad;
            committed_ad_summary = <div style={{marginTop: "10px", fontSize: "10px"}}>{committed_ad_count} Committed</div>
            committed_detail = ('');
            committed_summary = ('');
        }
        else {
            committed_detail = ('');
            committed_summary = ('');
        }

      var deleteButton = (this.state.cartItemQuantity > 0 ||  this.state.cartNetPrice > 0 || this.state.cartSalePrice > 0) && this.state.cartLotId == this.props.lot.id ? (<a href="javascript:void(0)" onClick={this.deleteSOFields} className="font-icon icon-clear" style={{marginLeft: "10px"}}></a>) : null;
      var inputClass = "redesigned app-product-input";

      if (this.props.orderId) {
          qty = (<input style={{width: "75px"}} type="number" placeholder="0" defaultValue={this.state.cartItemQuantity && this.state.cartLotId == lot.id ? this.state.cartItemQuantity : ''} name="items_to_add[][quantity]" className={inputClass} onKeyDown={this.clearField} onChange={this.updateQuantity} />);
          pid = (<input type="hidden" name="items_to_add[][product_id]" value={prd.id} />);
          lid = (<input type="hidden" name="items_to_add[][lot_id]" value={lot.id ? lot.id : 0} />);
          cid = (<input type="hidden" name="items_to_add[][ct_id]" value={lot.ct_id ? lot.ct_id : 0} />);
      }
      else {
          qty = (<input style={{width: "75px"}} type="number" placeholder="0"
                        defaultValue={this.state.cartItemQuantity && this.state.cartLotId == this.props.lot.id ? this.state.cartItemQuantity : ''}
                        className={inputClass} onKeyDown={this.clearField} onChange={this.updateSOQuantity}/>);
          pid = ('');
      }
      if (this.props.product.split_options.length > 0 && this.props.lot.status == 'available') {
          split_select_options = this.props.product.split_options.map(function (option) {
              return <option key={option.id}
                             value={option.id}>{option.name}</option>;
          });

          split_action = (
              <div style={{display: "inline-block", width: "100%", borderTop: "1px solid #DDD", marginTop: "5px"}}>
                  <table>
                      <tbody>
                      <tr>
                          <td>
                              <strong>Split:</strong>
                          </td>
                          <td>
                              <input style={{float: "left", textAlign: "center", width: "50px", marginLeft: "10px", height: "inherit"}} type="number" placeholder="0" className="redesigned split-qty"/>
                          </td>
                          <td>
                              <div style={{float: "left", marginLeft: "10px"}} className="split-options"><select className="split-product">{split_select_options}</select></div>
                          </td>
                          <td>
                              <div style={{float: "left", marginLeft: "10px"}}><button className="submit-split btn btn--primary btn--tiny">Split</button></div>
                          </td>
                      </tr>
                      </tbody>
                  </table>
              </div>)
      }
      else
          split_action = ('');

      if (this.props.product.undo_split_id && this.props.product.undo_split_id == this.props.lot.id)
          split_action = (
              <div style={{display: "inline-block", width: "100%", borderTop: "1px solid #DDD", marginTop: "5px"}}>
                  <div style={{float: "left", marginLeft: "10px"}}><button data-product-id={this.props.product.id} className="undo-submit-split btn btn--primary btn--tiny">Undo Split</button></div>
              </div>);
      else
          undo_split_action = ('');

      return (
        <tr className="cart_item" data-keep-when-zero="yes" data-cart-item={JSON.stringify(this.props.product.cart_item)}>
          <th style={{verticalAlign: 'top'}}>
            {lot_desc}
            {status}
            {committed_summary}
            {committed_ad_summary}
          </th>
          <td colSpan="4" style={{verticalAlign: 'top'}}>
            <div style={{float:"right", background:"#F7F7F7", width:"100%", borderRadius: "4px", border:"1px solid #D1D1D1", padding: "4px 0"}}>
                <div className="quantity" style={{float:"left", width:"33%", textAlign:"center"}}>
                    {qty}
                    {pid}
                    {lid}
                    {cid}
                </div>
                <div className="sale-price" style={{float:"left", width:"32%", textAlign:"center"}}>
                  {sale_entry}
                </div>
                <div className="net-price" style={{float:"left", width:"33%", textAlign:"center"}}>
                  {net_entry}
                </div>
                <div style={{float:"left", width:"2%", textAlign:"center", padding: "10px 0"}}>
                    {deleteButton}
                </div>
                <div>
                    <input type="hidden" className="lot-id" value={this.state.cartLotId && this.state.cartLotId == this.props.lot.id ? this.state.cartLotId : this.props.lot.id} />
                    <input type="hidden" className="ct-id" value={this.state.cartCtId && this.state.cartLotId == this.props.lot.id ? this.state.cartCtId : this.props.lot.ct_id} />
                </div>
                {split_action}
                {undo_split_action}
            </div>
              <div dangerouslySetInnerHTML={{__html: committed_detail }}></div>
              <div dangerouslySetInnerHTML={{__html: committed_ad_detail }}></div>
          </td>
          </tr>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductLots = ProductLots;
}).call(this);
