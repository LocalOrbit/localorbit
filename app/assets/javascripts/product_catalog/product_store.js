//= require reflux.min
//= require jquery

(function() {

  var ProductActions = Reflux.createActions([
    "setBaseUrl",
    "loadProducts",
    "loadMoreProducts",
    "updateProduct",
    "newQuery",
    "newFilters"
  ]);

  var ProductStore = Reflux.createStore({
    init: function() {
      this.catalog = {
        products: [],
        hasMore: true
      };
      this.url = window.location.protocol + "//" + window.location.host + "/api/v1/products";
      this.parameters = {
        offset: 0,
        category_ids: [],
        seller_ids: []
      };
      this.loading = false;
      this.listenTo(ProductActions.loadProducts, this.loadProducts);
      this.listenTo(ProductActions.loadMoreProducts, this.loadMoreProducts);
      this.listenTo(ProductActions.newQuery, this.newQuery);
      this.listenTo(ProductActions.newFilters, this.newFilters);
      this.listenTo(ProductActions.updateProduct, this.updateProduct);
    },

    newFilters: function(category_ids, seller_ids) {
      this.parameters.category_ids = category_ids;
      this.parameters.seller_ids = seller_ids;
      this.loadProducts();
    },

    newQuery: function(query) {
      this.parameters.query = query;
      ProductActions.loadProducts();
    },

    loadProducts: function() {
      this.loading = true;
      this.parameters.offset = 0;
      $.getJSON(this.url, this.parameters, this.onLoad, this.onLoadError);
    },

    onLoad: function(res) {
      this.catalog.products = [];
      this.onLoadMore(res);
    },

    loadMoreProducts: function() {
      if(this.loading || !this.catalog.hasMore) return;
      this.loading = true;
      this.parameters.offset = this.catalog.products.length;
      $.getJSON(this.url, this.parameters, this.onLoadMore, this.onLoadError);
    },

    onLoadMore: function(res) {
      this.catalog.products = this.catalog.products.concat(this.unpackProducts(res));
      this.catalog.hasMore = (this.catalog.products.length < res.product_total);
      this.trigger(this.catalog);
      this.loading = false;
    },

    unpackProducts: function(res) {
      var sellers = res.sellers || {};
      return _.map(res.products, function(general_product) {
        if (!general_product.available) {
          general_product.available = [];
        }
        return _.extend(general_product, sellers[general_product.seller_id]);
      });
    },

    updateProduct: function(productId, quantity, totalPrice) {
      // I can pull out a non-general product from our catalog, edit it, and automatically alter the catalog
      // itself because JS always passes objects by reference.
      //
      // Thanks, Javascript!
      var product = _.find(_.flatten(_.pluck(this.catalog.products, 'available')), {id: productId});
      product.cart_item_quantity = quantity;
      product.total_price = totalPrice;
      this.trigger(this.catalog);
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
