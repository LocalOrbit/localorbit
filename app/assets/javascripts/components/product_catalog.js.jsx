var ProductCatalog = React.createClass({
  propTypes: {
    cartUrl: React.PropTypes.string.isRequired,
    baseUrl: React.PropTypes.string.isRequired,
    limit: React.PropTypes.number.isRequired
  },

  getInitialState: function() {
    return {
      products: []
    };
  },

  offset: 0,

  isLoading: false,

  query: '',

  componentDidMount: function() {
    this.getMoreProducts();
  },

  newSearch: function(event) {
    this.offset = 0;
    this.query = event.target.value;
    this.filterProducts();
  },

  getMoreProducts: function() {
    this.getProducts()
      .done(function(res) {
        var newProducts = this.state.products.concat(res.products);
        this.isLoading = false;
        this.setState({products: newProducts});
      }.bind(this));
  },

  filterProducts: function() {
    this.getProducts()
      .done(function(res) {
        this.isLoading = false;
        this.setState({products: res.products});
      }.bind(this));
  },

  getProducts: function() {
    var deferred = $.Deferred();
    this.isLoading = true;
    var url = this.props.baseUrl + '/api/v1/products.json';
    var parameters = {
      offset: this.offset,
      limit: this.props.limit,
      query: this.query
    };

    $.getJSON(url, parameters, deferred.resolve, deferred.reject);

    return deferred.promise();
  },

  onInfiniteLoad: function() {
    if (this.isLoading) return;
    this.offset += 10;
    this.getMoreProducts();
  },

  render: function() {
    return (
      <div>
        <h1>Filter Products</h1>
        <div className="column--full column--guttered" style={{marginBottom: "50px"}}>
          <input className="typeahead" placeholder="Try 'orange fruit'" onKeyUp={this.newSearch} />
        </div>
        <ProductTable
          limit={10}
          products={this.state.products}
          cartUrl={this.props.cartUrl}
          baseUrl={this.props.baseUrl}
          onInfiniteLoad={this.onInfiniteLoad}
        />
      </div>
    );
  }
});
