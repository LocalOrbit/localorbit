//= require reflux.min
//= require jquery

(function() {
  var ProductActions = Reflux.createActions([
    "loadProducts",
    "loadMoreProducts"
  ]);

  var ProductStore = Reflux.createStore({
    init: function() {
      this.data = {
        products: [],
        hasMore: true
      };
      this.loading = false;
      this.listenTo(ProductActions.loadProducts, this.loadProducts);
      this.listenTo(ProductActions.loadMoreProducts, this.loadMoreProducts);
    },

    loadProducts: function(url, parameters) {
      if(this.loading) return;
      this.loading = true;
      parameters.offset = 0;
      $.getJSON(url, parameters, this.onLoad, this.onLoadError);
    },

    onLoad: function(res) {
      this.data.products = res.products;
      this.data.hasMore = (this.data.products.length < res.product_total);
      this.trigger(this.data);
      this.loading = false;
    },

    loadMoreProducts: function(url, parameters) {
      if(this.loading || !this.data.hasMore) return;
      this.loading = true;
      parameters.offset = this.data.products.length;
      $.getJSON(url, parameters, this.onLoadMore, this.onLoadError);
    },

    onLoadMore: function(res) {
      this.data.products = this.data.products.concat(res.products);
      this.data.hasMore = (this.data.products.length < res.product_total);
      this.trigger(this.data);
      this.loading = false;
    },

    onLoadError: function(err) {
      console.error('Error loading products', err);
      this.loading = false;
    }
  });

  window.lo = window.lo || {};
  _.extend(window.lo, {
    ProductStore: ProductStore,
    ProductActions: ProductActions
  });
}).call(this);