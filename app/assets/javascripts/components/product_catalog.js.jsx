var ProductCatalog = React.createClass({
  getInitialState: function() {
    return {
      query: '',
      start: 0,
      products: [ ]
    };
  },

  getProducts: function() {
    $.getJSON(this.props.baseUrl + '/api/v1/products.json', function(res) {
      this.setState({products: res.products});
    }.bind(this));
  },

  componentDidMount: function() {
    this.getProducts();
  },

  handleUserInput: function(query) {
    this.setState({ query: query });
  },

  //TODO: handle scroll, new user input

  render: function() {
    return (
      <div id="">
        <ProductSearch
          query={this.state.query}
        />
        <ProductTable
          products={this.state.products}
          cartUrl={this.props.cartUrl}
        />
      </div>
    );
  }
});
