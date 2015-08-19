//= require react-infinite-scroll.min

var ProductTable = React.createClass({
  propTypes: {
    products: React.PropTypes.array.isRequired,
    productTotal: React.PropTypes.number.isRequired,
    offset: React.PropTypes.number.isRequired,
    loading: React.PropTypes.bool.isRequired
  },

  render: function() {
    var rows = this.props.products.map(function(product) {
      return ( <ProductRow key={product.id} product={product} /> )
    });

    var hasMore = (10 + this.props.offset < this.props.productTotal) || this.props.loading

    return (
      <table id="product-search-table" className="product-table product-table--user cart_items" data-cart-url={this.props.cartUrl}>
          <InfiniteScroll
            pageStart={0}
            hasMore={hasMore}
            threshold={50}
            loadMore={this.props.onInfiniteLoad}
            loader={(<th>Loading products....</th>)}
          >
            {rows}
          </InfiniteScroll>
      </table>
    );
  }
});
