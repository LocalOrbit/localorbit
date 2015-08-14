var ProductCatalog = React.createClass({
  propTypes: {
    cartUrl: React.PropTypes.string.isRequired,
    baseUrl: React.PropTypes.string.isRequired,
    limit: React.PropTypes.number.isRequired
  },

  getInitialState: function() {
    return {
      query: '',
      products: []
    };
  },

  offset: 0,

  isLoading: false,

  componentDidMount: function() {
    this.getProducts();
  },

  getProducts: function() {
    this.isLoading = true;
    var url = this.props.baseUrl + '/api/v1/products.json';
    var parameters = {offset: this.offset, limit: this.props.limit};

    $.getJSON(url, parameters, function(res) {
        var newProducts = this.state.products.concat(res.products);
        this.isLoading = false;
        this.setState({products: newProducts});
      }.bind(this));
  },

  onInfiniteLoad: function() {
    if (this.isLoading) return;
    this.offset += 10;
    this.getProducts();
  },

  render: function() {
    return (
      <div>
        <h1>Filter Products</h1>

        <div className="column--full column--guttered" style={{marginBottom: "50px"}}>
          <input className="typeahead" placeholder="Try 'orange fruit'" />
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
