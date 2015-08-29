(function() {

  var ProductRow = React.createClass({
    propTypes: {
      hideImages: React.PropTypes.bool.isRequired,
      product: React.PropTypes.shape({
        id: React.PropTypes.number.isRequired,
        name: React.PropTypes.string.isRequired,
        second_level_category_name: React.PropTypes.string,
        unit: React.PropTypes.string.isRequired,
        short_description: React.PropTypes.string,
        long_description: React.PropTypes.string,
        cart_item: React.PropTypes.object,
        cart_item_quantity: React.PropTypes.number,
        max_available: React.PropTypes.number,
        price_for_quantity: React.PropTypes.string,
        total_price: React.PropTypes.string,
        cart_item_persisted: React.PropTypes.bool,
        image_url: React.PropTypes.string,
        who_story: React.PropTypes.string,
        how_story: React.PropTypes.string,
        location_label: React.PropTypes.string,
        location_map_url: React.PropTypes.string,
        prices: React.PropTypes.array
      })
    },

    getInitialState: function() {
      return {
        cartItemQuantity: this.props.product.cart_item_quantity
      };
    },
    updateQuantity: function(event) {
      this.setState({cartItemQuantity: event.target.value});
    },
    // componentDidMount: function() {
    //   window.insertCartItemEntry($(this.getDOMNode()));
    // },
    render: function() {
      var product = this.props.product;

      return (
        <div className="row product-listing" data-cart-item={JSON.stringify(product.cart_item)}>
          <div className="product-details-container column column--five-twelfths">
            <img style={{display: (this.props.hideImages) ? "none" : ""}} className="product-image" src={product.image_url}/>
            <div className="product-details">
              <a href={"/products/" + product.id}><h3>{product.name}</h3></a>
              <h5>From: <a href={"/sellers/" + product.seller_id}>{product.seller_name}</a></h5>
              <p>{product.short_description}</p>
              <ul className="meta list-naked l-inline-list clear-before">
                <li className="organization-name">
                  <a className="popup-toggle" href={'#product-'+product.id+'-who'} tabIndex="-1"><i className="font-icon icon-credit"></i>&nbsp;Who</a>
                  <div className="who-info is-hidden with-anchor top-anchor popup" id={'product-'+product.id+'-who'}>
                    <div className="popup-header">
                      Who <button className="close"><i className="font-icon icon-close"></i></button>
                    </div>
                    <div className="popup-body">
                      {product.who_story}
                    </div>
                  </div>
                </li>
                <li className="how-story">
                  <a className="popup-toggle" href={'#product-'+product.id+'-how'} tabIndex="-1"><i className="font-icon icon-archive"></i> How</a>
                  <div className="how-info is-hidden with-anchor top-anchor popup" id={'product-'+product.id+'-how'}>
                    <div className="popup-header">
                      How <button className="close"><i className="font-icon icon-close"></i></button>
                    </div>
                    <div className="popup-body">
                      {product.how_story}
                    </div>
                  </div>
                </li>
                <li className="where">
                  <a className="popup-toggle" href={'#product-'+product.id+'-where'} tabIndex="-1"><i className="font-icon icon-direction"></i> Where</a>
                  <div className="where-info is-hidden with-anchor top-anchor popup" id={'product-'+product.id+'-where'}>
                    <div className="popup-header">
                      Durand, MI     <button className="close"><i className="font-icon icon-close"></i></button>
                    </div>
                    <img className="location-map" alt="" src="" data-src={product.location_map_url}/>
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
                <lo.ProductUnitPrices
                  unit={product.unit}
                  prices={product.prices}
                  total_price={product.total_price}
                  max_available={product.max_available}
                  cart_item_quantity={product.cart_item_quantity}
                />
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
