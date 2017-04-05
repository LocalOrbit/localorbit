//= require product_catalog/mixins/product_row_mixin.js

(function() {
  var ProductRow = React.createClass({
    propTypes: {
        purchaseOrder: React.PropTypes.bool,
        salesOrder: React.PropTypes.bool,
        consignmentMarket: React.PropTypes.bool
    },

    mixins: [window.lo.ProductRowMixin],

    render: function() {
      var self = this;
      var gp = this.props.product;
      var supplierStyle;
      var lots;
      var unit_prices;
      var total_cost_header;
      var lot_qty_header;
      var sale_price_header;
      var net_price_header;
      var consignment_qty_header;
      var order_qty_header;

      // Initialize the convenience variable
      var product_id = "product-"+gp.id+"-long-description";

      // The 'plus sign' link HTML, keyed to the product id
      var description_link = <a className="popup-toggle" href={'#'+product_id} tabIndex="-1"><i className="font-icon icon-plus-circle"> </i></a>;

      // The long description HTML
      var long_description = <div className="long-description-info is-hidden with-anchor top-anchor popup" id={product_id}><div className="popup-header">Details <button className="close"><i className="font-icon icon-close"></i></button></div><div className="popup-body">{gp.long_description}</div></div>

      if (self.props.salesOrder && self.props.consignmentMarket) {
          _.map(gp.available, function (p) {
              lots = _.map(p.lots, function (l) {
                  return <lo.ProductLots key={l.id} product={p} lot={l} orderId={self.props.orderId} purchaseOrder={self.props.purchaseOrder}
                                         salesOrder={self.props.salesOrder}/>
              })
          });
          total_cost_header = ('');
          lot_qty_header = (<th style={{width: 100, textAlign: "center", color:"#727070", textTransform:"uppercase", fontWeight: "bold", fontSize: "11px"}}>Lot / Quantity</th>);
          sale_price_header = (<th style={{width: 100, textAlign: "center", color:"#727070", textTransform:"uppercase", fontWeight: "bold", fontSize: "11px"}}>Sale Price</th>);
          net_price_header = (<th style={{width: 100, textAlign: "center", color:"#727070", textTransform:"uppercase", fontWeight: "bold", fontSize: "11px"}}>Net Price</th>);
          consignment_qty_header = (<th style={{width: 100, textAlign: "center", color:"#727070", textTransform:"uppercase", fontWeight: "bold", fontSize: "11px"}}>Order QTY</th>);
      }
      else {
          lots = ('');
          consignment_qty_header = ('');
          lot_qty_header = ('');
          sale_price_header = (<th></th>);
          net_price_header = (<th></th>);
          order_qty_header = (<th style={{width: 100, textAlign: "center", color:"#727070", textTransform:"uppercase", fontWeight: "bold", fontSize: "11px"}}>Order QTY</th>);
          total_cost_header = (<th style={{
              width: 100,
              textAlign: "center",
              color: "#727070",
              textTransform: "uppercase",
              fontWeight: "bold",
              fontSize: "11px"
          }}>
              {(this.props.purchaseOrder) ? "" : "Total Cost"}
          </th>);
      }

      //var unit_prices = '';
      if (self.props.purchaseOrder || !self.props.consignmentMarket)
          unit_prices = _.map(gp.available, function(p) {
            return <lo.ProductUnitPrices key={p.id} product={p} promo={self.props.promo} orderId={self.props.orderId} purchaseOrder={self.props.purchaseOrder} salesOrder={self.props.salesOrder} consignmentMarket={self.props.consignmentMarket} /> });
      else
          unit_prices = ('');

      return (
        <div className="row product-listing">
          <div className="product-details-container column column--five-twelfths">
            <img style={{display: (this.props.hideImages) ? "none" : ""}} className="product-image" src={gp.image_url}/>
            <div className="product-details" style={{ width: (this.props.supplierOnly) ? "unset" : "", marginTop: (this.props.supplierOnly) ? "10px" : "" }}>
              <h3 className="name">{gp.name}</h3>
              <h5>From: <a href={"/sellers/" + gp.seller_id}>{gp.seller_name}</a></h5>
              <p>{gp.short_description} {(gp.long_description) ? description_link : "" }</p>
              {(gp.long_description) ? long_description : ""}
              <ul className="meta list-naked l-inline-list clear-before">
                <li className="organization-name">
                  <a className="popup-toggle" href={'#product-'+gp.id+'-who'} tabIndex="-1"><i className="font-icon icon-credit"></i>&nbsp;Who</a>
                  <div className="who-info is-hidden with-anchor top-anchor popup" id={'product-'+gp.id+'-who'}>
                    <div className="popup-header">
                      Who <button className="close"><i className="font-icon icon-close"></i></button>
                    </div>
                    <div className="popup-body">
                      {gp.who_story}
                    </div>
                  </div>
                </li>
                <li className="how-story">
                  <a className="popup-toggle" href={'#product-'+gp.id+'-how'} tabIndex="-1"><i className="font-icon icon-archive"></i> How</a>
                  <div className="how-info is-hidden with-anchor top-anchor popup" id={'product-'+gp.id+'-how'}>
                    <div className="popup-header">
                      How <button className="close"><i className="font-icon icon-close"></i></button>
                    </div>
                    <div className="popup-body">
                      {gp.how_story}
                    </div>
                  </div>
                </li>
                <li className="where">
                  <a className="popup-toggle" href={'#product-'+gp.id+'-where'} tabIndex="-1"><i className="font-icon icon-direction"></i> Where</a>
                  <div className="where-info is-hidden with-anchor top-anchor popup" id={'product-'+gp.id+'-where'}>
                    <div className="popup-header">
                      {gp.location_label}
                      <button className="close"><i className="font-icon icon-close"></i></button>
                    </div>
                    <img className="location-map" alt="" src="" data-src={gp.location_map_url}/>
                  </div>
                </li>
              </ul>
            </div>
          </div>
          <div className="product-details-spacer"> </div>
          <div className="product-pricing column column--seven-twelfths">
            <table>
              <thead>
                <tr>
                    {lot_qty_header}
                    {consignment_qty_header}
                    {sale_price_header}
                    {net_price_header}
                    {order_qty_header}
                    {total_cost_header}
                </tr>
              </thead>
              <tbody>
              {lots}
              {unit_prices}
              </tbody>
            </table>
            <div className="errormsg" id={'product-'+gp.id} style={{ fontSize: 11, textAlign:"right", color:"red"}}></div>
          </div>
          <div style={{clear:"both"}}></div>
        </div>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductRow = ProductRow;
}).call(this);
