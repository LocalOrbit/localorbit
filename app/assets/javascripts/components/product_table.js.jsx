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
      <div className="product-list" style={{padding: "20px"}} data-cart-url={this.props.cartUrl}>
        <InfiniteScroll
          pageStart={0}
          hasMore={hasMore}
          threshold={50}
          loadMore={this.props.onInfiniteLoad}
          loader={(<p>Loading products....</p>)}
        >
          <div className="product-images-link row pull-right"> <a className="" href=""><i className="font-icon" data-icon=""></i> Hide Product Images</a> </div>
          {rows}
        </InfiniteScroll>
      </div>
    );
  }
});
