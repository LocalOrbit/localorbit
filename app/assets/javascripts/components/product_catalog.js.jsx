//= require underscore
//= require moment.min

var ProductCatalog = React.createClass({
  propTypes: {
    cartUrl: React.PropTypes.string.isRequired,
    baseUrl: React.PropTypes.string.isRequired,
    limit: React.PropTypes.number.isRequired,
    deliveryDate: React.PropTypes.string.isRequired
  },

  getInitialState: function() {
    return {
      products: [],
      productTotal: 0,
      query: '',
      offset: 0,
      loading: true,
      deliveryDate: moment(this.props.deliveryDate)
    };
  },

  componentWillMount: function() {
    this.filterProducts = _.debounce(this.filterProducts, 500, false);
    this.onInfiniteLoad = _.debounce(this.onInfiniteLoad, 500);
  },

  componentDidMount: function() {
    this.getMoreProducts();
  },

  newSearch: function(event) {
    this.filterProducts(event.target.value);
  },

  getMoreProducts: function() {
    this.getProducts()
      .done(function(res) {
        var newProducts = this.state.products.concat(res.products);
        this.setState({products: newProducts, productTotal: res.product_total});
      }.bind(this))
      .always(function(res) {
        this.setState({loading: false});
      }.bind(this));
  },

  filterProducts: function(query) {
    this.setState({query: query, products: [], productTotal: 0, offset: 0, loading: true});
    this.getProducts()
      .done(function(res) {
        this.setState({products: res.products, productTotal: res.product_total});
      }.bind(this))
      .always(function(res) {
        this.setState({loading: false});
      }.bind(this));
  },

  getProducts: function() {
    this.setState({loading: true});
    var deferred = $.Deferred();
    var url = this.props.baseUrl + '/api/v1/products.json';
    var parameters = {
      offset: this.state.offset,
      limit: this.props.limit,
      query: this.state.query
    };

    $.getJSON(url, parameters, deferred.resolve, deferred.reject);

    return deferred.promise();
  },

  onInfiniteLoad: function() {
    if (this.state.loading || this.state.productTotal === 0) return;
    this.setState({offset: this.state.offset + 10});
    this.getMoreProducts();
  },

  render: function() {
    var matchingText = this.state.productTotal + ' matching and available results found';
    if (this.state.query.length > 0 && this.state.query.length < 3) {
      matchingText += '. (Please enter 3 or more characters to filter results.)'
    }
    else if(this.state.query.length > 0) {
      matchingText += ' for "'+this.state.query+'".';
    }
    else {
      matchingText += '.'
    }

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
        <p style={{display: (this.state.loading) ? 'none' : 'block', minHeight: '20px'}}><strong>{matchingText}</strong></p>
        <ProductTable
          limit={10}
          products={this.state.products}
          productTotal={this.state.productTotal}
          offset={this.state.offset}
          loading={this.state.loading}
          cartUrl={this.props.cartUrl}
          baseUrl={this.props.baseUrl}
          onInfiniteLoad={this.onInfiniteLoad}
        />
      </div>
    );
  }
});
