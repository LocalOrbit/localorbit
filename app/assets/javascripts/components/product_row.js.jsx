var ProductRow = React.createClass({
  propTypes: {
    product: React.PropTypes.shape({
      id: React.PropTypes.number.isRequired,
      name: React.PropTypes.string.isRequired,
      second_level_category_name: React.PropTypes.string,
      unit_with_description: React.PropTypes.string,
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
  componentDidMount: function() {
    window.insertCartItemEntry($(this.getDOMNode()));
  },
  render: function() {
    var description, prices;
    var product = this.props.product;
    if (product.long_description) {
      description =
        <div className="short_description">
          <p>
            {product.short_description}
            <a href={'#product-' + product.id + '-long-description'} className='popup-toggle' tabIndex='-1'><i className="font-icon icon-plus-circle"/></a>
          </p>
          <div className="long-description-info is-hidden with-anchor top-anchor popup" id={"product-" + product.id + "-long-description"}>
            <div className="popup-header">
              Details <button className="close"><i className="font-icon icon-close"></i></button>
            </div>
            <div className="popup-body">
              {product.long_description}
            </div>
          </div>
        </div>
    }
    else {
      description =
        <div className="short_description">
          {product.short_description}
        </div>
    }
    prices = product.prices.map(function(price) {
      if(price.organization_id) {
        return <li className="negotiated"><span className="unit-price">{price.sale_price}</span> <span className="tier">{ price.formatted_units }</span><span className="tooltip tooltip--naked tooltip--notice" data-tooltip="This is a negotiated price specific to you!"><i className="font-icon" data-icon="&#xe01f;"></i></span></li>
      }
      else {
        return <li><span className="unit-price">{price.sale_price}</span> <span className="tier">{ price.formatted_units }</span></li>
      }
    });

    return (
      <tr className="product product-row cart_item" data-cart-item={JSON.stringify(product.cart_item)}>
        <td className="info">
          <div className="product-image"> <img src={product.image_url} /> </div>
          <h3 className="name"><a href={"/products/" + product.id} tabIndex="-1">{product.name}</a></h3>

          {description}

          <ul className="meta list-naked l-inline-list clear-before">
            <li className="organization-name">
              <a href={"#product-"+product.id+"-who"} tabIndex='1' className='popup-toggle'><i className="font-icon icon-credit"></i> {product.seller_name}</a>
              <div className="who-info is-hidden with-anchor top-anchor popup" id={"product-" + product.id + "-who"}>
                <div className="popup-header">
                  Who <button className="close"><i className="font-icon icon-close"></i></button>
                </div>
                <div className="popup-body">
                  {product.who_story}
                </div>
              </div>
            </li>
            <li className="how-story">
              <a href={'#product-'+product.id+'-how'} tabIndex='-1' className='popup-toggle'><i className="font-icon icon-archive"></i> How</a>
              <div className="how-info is-hidden with-anchor top-anchor popup" id={"product-" +product.id+"-how"}>
                <div className="popup-header">
                  How <button className="close"><i className="font-icon icon-close"></i></button>
                </div>
                <div className="popup-body">
                  {product.how_story}
                </div>
              </div>
            </li>
            <li className="where">
              <a href={"#product-"+product.id+"-where"} className="popup-toggle" tabIndex="-1"><i className="font-icon icon-direction"></i> Where</a>
              <div className="where-info is-hidden with-anchor top-anchor popup" id={"product-" + product.id + "-where"}>
                <div className="popup-header">
                  {product.location_label}
                  <button className="close"><i className="font-icon icon-close"></i></button>
                </div>
                <img className="location-map" alt="" src="" data-src={product.location_map_url}/>
              </div>
            </li>
            <li className="mobile-only product-image-alt">
              <a href={"#product-" + product.id +"-image"} className="product-toggle" tabIndex="-1"><i className="font-icon icon-picture"></i> Product Image</a>
              <div className="image-info is-hidden with-anchor top-anchor popup" id={"product-" + product.id +"-image"}>
                <div className="popup-header">
                   {product.name}
                   <button className="close"><i className="font-icon icon-close"></i></button>
                </div>
                <img src={product.image_url}/>
              </div>
            </li>
          </ul>
        </td>
        <td className="pricing">
          <ul className="tiers">
            {prices}
          </ul>
        </td>
        <td className="quantity">
          <span>
            <input name="quantity" type="number" size="3" min="0" value={this.state.cartItemQuantity} onChange={this.updateQuantity} max={product.max_available}/><br/>
            <span className="price-for-quantity">{product.price_for_quantity}</span>
          </span>
        </td>
        <td className="total price">{product.total_price}</td>
        <td className="product-clear"><a href="#" className={"font-icon icon-clear" + (product.cart_item_persisted) ? '': 'is-hidden'} tabIndex="-1"/></td>
      </tr>
    );
  }
});
