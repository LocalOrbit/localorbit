//= require react-infinite-scroll.min
//= require product_catalog/product_store

(function() {
  var isFirstTopCategory = true, isFirstSecondCategory = true;
  var current_top_level_category = null, previous_top_level_category = null;
  var current_second_level_category = null, previous_second_level_category = null;

  var ProductTable = React.createClass({
    propTypes: {
      url: React.PropTypes.string.isRequired,
      cartUrl: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
      return {
        hideImages: false,
        hasMore: true,
        featuredPromotion: null,
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
        featuredPromotion: res.featuredPromotion,
        products: res.products,
        hasMore: res.hasMore
      });
      isFirst = true;
    },

    toggleImages: function() {
      this.setState({hideImages: !this.state.hideImages});
    },

    buildRow: function(product, isMobile, promo) {
        var addTopCategory=null, addSecondCategory=null;
        current_top_level_category = product.top_level_category_name;
        if (previous_top_level_category != current_top_level_category || isFirstTopCategory) {
            previous_top_level_category = current_top_level_category;

            addTopCategory = (<lo.ProductCategoryRow category={current_top_level_category}/>);
            isFirstTopCategory = false;
        }
        else
            addTopCategory = null;

        current_second_level_category = product.second_level_category_name;
        if (previous_second_level_category != current_second_level_category || isFirstSecondCategory) {
            previous_second_level_category = current_second_level_category;

            addSecondCategory = (<lo.ProductSecondCategoryRow category={current_second_level_category}/>);
            isFirstSecondCategory = false;
        }
        else
            addSecondCategory = null;

        is_promo = (promo == product.id)

        if (isMobile) {
            return (<div>
                {addTopCategory}
                {addSecondCategory}
                <lo.MobileProductRow key={product.id} product={product} hideImages={this.state.hideImages} promo={is_promo}/>
            </div> );
        }
        else {
            return (<div>
                {addTopCategory}
                {addSecondCategory}
                <lo.ProductRow key={product.id} product={product} hideImages={this.state.hideImages} promo={is_promo}/>
            </div> );
        }
    },

    render: function() {
      var MOBILE_WIDTH = 480;
      var self = this;

      isFirstTopCategory = true, isFirstSecondCategory = true;

      var isMobile = self.state.width <= MOBILE_WIDTH;
      var promo = null;
      if (this.state.featuredPromotion && this.state.featuredPromotion.details != null) {
          promo = (<lo.ProductFeaturedPromotion hideImages={this.state.hideImages} promo={self.state.featuredPromotion} />)
      }
      var rows = self.state.products.map(function(product) {
        return self.buildRow(product, isMobile, promo ? self.state.featuredPromotion.product.id : false);
      });

      if(rows.length === 0 && this.state.hasMore === false) {
        rows = (<p>No products found. Try broadening your search, removing any filters, or changing your delivery date to see more results.</p>)
      }

      return (
        <div className="product-list cart_items" style={{padding: "20px"}} data-cart-url={this.props.cartUrl}>
          <InfiniteScroll
            pageStart={0}
            hasMore={self.state.hasMore}
            threshold={500}
            loadMore={self.loadMore}
            loader={(<p>Loading products....</p>)}
          >
            <div id="product-search-table" className="product-images-link row pull-right"> <a href="javscript:void(0);" onClick={self.toggleImages}><i className="font-icon" data-icon=""></i> {(self.state.hideImages) ? "Show " : "Hide "} Product Images</a> </div>
              {promo}
              {rows}
          </InfiniteScroll>
        </div>
      );
    }
  });

  window.lo = window.lo || {};
  window.lo.ProductTable = ProductTable;
}).call(this);
