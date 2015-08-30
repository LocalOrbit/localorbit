//= require underscore
//= require moment.min
//= require product_catalog/product_store

(function() {
  window.lo = window.lo || {};

  var ProductCatalog = React.createClass({
    propTypes: {
      cartUrl: React.PropTypes.string.isRequired,
      baseUrl: React.PropTypes.string.isRequired,
      limit: React.PropTypes.number.isRequired,
      products: React.PropTypes.array,
      deliveryDate: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
      return {
        deliveryDate: moment(this.props.deliveryDate)
      };
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
            onInfiniteLoad={function() {}}
          />
        </div>
      );
    }
  });

  window.lo.ProductCatalog = ProductCatalog;
}).call(this);
