//= require underscore
//= require moment.min
//= require product_catalog/store

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
          <div className="row catalog-search-container">
            <div className="catalog-search column column--half pull-left">
              <input className="" type="text" placeholder="Search..."/>
              <a href className="btn--secondary btn pull-right">Filter</a>
              <div className="filter-tags pull-left">
                <span className="filter-tags-title">Filtering by: </span>
                <a href>Berries & Cherries<i className="font-icon icon-close"></i></a>
                <a href>Apples<i className="font-icon icon-close"></i></a>
                <a href>Dried Fruits<i className="font-icon icon-close"></i></a>
                <a href>Nuts & Seeds<i className="font-icon icon-close"></i></a>
              </div>
            </div>
            <div className="order-information-container column column--half pull-left">
              Delivery date: <strong>{this.state.deliveryDate.format('dddd, MMM. D, YYYY')}</strong><br/>
              Time left to order: <strong>{this.state.deliveryDate.fromNow(true)}</strong><br/>
              <a href="/sessions/deliveries/new?redirect_back_to=%2Fproducts">Change delivery options</a>
            </div>
            <div style={{clear:"both"}}></div>
          </div>
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
