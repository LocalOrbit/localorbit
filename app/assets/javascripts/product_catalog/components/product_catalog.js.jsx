//= require underscore
//= require moment.min
//= require product_catalog/product_store

(function() {
  window.lo = window.lo || {};

  var ProductCatalog = React.createClass({
    propTypes: {
      cartUrl: React.PropTypes.string.isRequired,
      baseUrl: React.PropTypes.string.isRequired,
      deliveryDate: React.PropTypes.string.isRequired
    },

    render: function() {
      return (
        <div>
          <lo.ProductFilter
            deliveryDate={this.props.deliveryDate}
          />
          <lo.ProductTable
            limit={10}
            filter={null}
            cartUrl={this.props.cartUrl}
            url={this.props.baseUrl}
          />
        </div>
      );
    }
  });

  window.lo.ProductCatalog = ProductCatalog;
}).call(this);
