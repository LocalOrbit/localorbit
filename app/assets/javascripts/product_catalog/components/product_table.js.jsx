//= require react-infinite-scroll.min
//= require product_catalog/product_store

(function() {
  var current_top_level_category = null, previous_top_level_category = null;
  var isFirst = true;

  var ProductTable = React.createClass({
    propTypes: {
      url: React.PropTypes.string.isRequired,
      cartUrl: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
      return {
        hideImages: false,
        hasMore: true,
        products: []
      };
    },

    componentWillMount: function() {
      this.updateDimensions();
      window.lo.ProductStore.listen(this.onProductsChange);
      window.lo.ProductActions.loadProducts(this.props.url);
    },

    componentDidMount: function() {
      window.addEventListener('resize', this.updateDimensions);
    },

    componentWillUnmount: function() {
      window.removeEventListener('resize', this.updateDimensions);
    },

    updateDimensions: function() {
      this.setState({width: $(window).width()});
    },


    loadMore: function() {
      window.lo.ProductActions.loadMoreProducts(this.props.url);
    },

    onProductsChange: function(res) {
      this.setState({
        products: res.products,
        hasMore: res.hasMore
      });
      isFirst = true;
    },

    toggleImages: function() {
      this.setState({hideImages: !this.state.hideImages});
    },

    buildRow: function(product, isMobile) {
        var addCategory=null;
        current_top_level_category = product.top_level_category_name;
        if (previous_top_level_category != current_top_level_category || isFirst) {
            previous_top_level_category = current_top_level_category;

            if (isFirst) {
                addCategory = (<lo.ProductCategoryRow category={current_top_level_category}/>);
                isFirst = false;
            }
            else
                return (<lo.ProductCategoryRow category={current_top_level_category} />);
        }

        if(isMobile) {
            return ( <div> {addCategory} <lo.MobileProductRow key={product.id} product={product} hideImages={this.state.hideImages} /> </div> );
        }
        else {
            return ( <div> {addCategory} <lo.ProductRow key={product.id} product={product} hideImages={this.state.hideImages} /> </div> );
        }
    },

    render: function() {
      var MOBILE_WIDTH = 480;
      var self = this;
      var isMobile = self.state.width <= MOBILE_WIDTH;
      var rows = self.state.products.map(function(product) {
        return self.buildRow(product, isMobile);
      });

      if(rows.length === 0 && this.state.hasMore === false) {
        rows = (<p>No products found. Try broadening your search, removing any filters, or changing your delivery date to see more results.</p>)
      }

      return (
        <div className="product-list cart_items" style={{padding: "20px"}} data-cart-url={this.props.cartUrl}>
          <InfiniteScroll
            pageStart={0}
            hasMore={self.state.hasMore}
            threshold={300}
            loadMore={self.loadMore}
            loader={(<p>Loading products....</p>)}
          >
            <div id="product-search-table" className="product-images-link row pull-right"> <a href="javscript:void(0);" onClick={self.toggleImages}><i className="font-icon" data-icon=""></i> {(self.state.hideImages) ? "Show " : "Hide "} Product Images</a> </div>
            {rows}
          </InfiniteScroll>
        </div>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductTable = ProductTable;
}).call(this);
