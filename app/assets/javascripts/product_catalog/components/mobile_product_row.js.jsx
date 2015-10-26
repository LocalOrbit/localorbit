(function() {

  var MobileProductRow = React.createClass({
    mixins: [window.lo.ProductRowMixin],

    render: function() {
      var gp = this.props.product;
      var unitPrices = _.map(gp.available, function(p) {
        return <lo.MobileProductUnitPrices product={p} />
      });

      var inputs = _.map(gp.available, function(p) {
        return <lo.MobileProductInput product={p} />
      });

      return (
        <div className="row product-listing mobile">
          <div className="product-listing-header">
            <div className="column--three-fourths pull-left">
              <h3><a href={"/products/" + gp.id}>{gp.name}</a></h3>
              <h5>From: <span style={{fontStyle: "italic"}}>{gp.seller_name}</span></h5>
            </div>
            <div className="column--fourth pull-left">
              <a className="btn btn--info btn--small pull-right" style={{padding: "4px 10px", fontSize: "14px"}}><i className="font-icon icon-plus-circle"></i> Info</a>
            </div>
          </div>
          <div style={{clear: "both"}}></div>
          <div style={{marginTop: "26px"}}>
            <table className="pricing-table-mobile">
              <thead>
                <tr><th colSpan="4">
                  PRICING PER UNIT
                </th>
              </tr></thead>
              <tbody>
                {unitPrices}
              </tbody>
            </table>
            <br/>
          </div>
          {inputs}
          <div style={{clear:"both"}}></div>
        </div>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.MobileProductRow = MobileProductRow;
}).call(this);
