(function() {

  var ProductRow = React.createClass({
    propTypes: {
      hideImages: React.PropTypes.bool.isRequired,
      product: React.PropTypes.shape({
        id: React.PropTypes.number.isRequired,
        name: React.PropTypes.string.isRequired,
        second_level_category_name: React.PropTypes.string,
        short_description: React.PropTypes.string,
        long_description: React.PropTypes.string,
        image_url: React.PropTypes.string,

        available: React.PropTypes.arrayOf(React.PropTypes.shape({
          id: React.PropTypes.number.isRequired,
          unit: React.PropTypes.string.isRequired,
          prices: React.PropTypes.array,
          total_price: React.PropTypes.string,
          max_available: React.PropTypes.number,
          price_for_quantity: React.PropTypes.string,
          cart_item_persisted: React.PropTypes.bool,
          cart_item_quantity: React.PropTypes.number,
          cart_item: React.PropTypes.object
        })).isRequired,

        who_story: React.PropTypes.string,
        how_story: React.PropTypes.string,
        location_label: React.PropTypes.string,
        location_map_url: React.PropTypes.string
      })
    },

    render: function() {
      var gp = this.props.product;
      var unit_prices = _.map(gp.available, function(p) {
        return <lo.ProductUnitPrices product={p} />
      });

      return (
        <div className="row product-listing">
          <div className="product-details-container column column--five-twelfths">
            <img style={{display: (this.props.hideImages) ? "none" : ""}} className="product-image" src={gp.image_url}/>
            <div className="product-details">
              <h3>{gp.name}</h3>
              <h5>From: <a href={"/sellers/" + gp.seller_id}>{gp.seller_name}</a></h5>
              <p>{gp.short_description}</p>
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
                <th></th>
                <th></th>
                <th style={{textAlign: "center", color:"#727070", textTransform:"uppercase", fontWeight: "bold", fontSize: "11px"}}>
                  Order QTY
                </th>
                <th style={{textAlign: "center", color:"#727070", textTransform:"uppercase", fontWeight: "bold", fontSize: "11px"}}>
                  Total Cost
                </th>
              </thead>
              <tbody>
                {unit_prices}
              </tbody>
            </table>
          </div>
          <div style={{clear:"both"}}></div>
        </div>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductRow = ProductRow;
}).call(this);
