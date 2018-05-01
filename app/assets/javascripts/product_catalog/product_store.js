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
        featuredPromotion: null,
        products: [],
        hasMore: true
      };
      // this.url = window.location.protocol + "//" + window.location.host + "/api/v1/products";
      this.orderId = null;
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

    loadProducts: function(url) {
      this.loading = true;
      this.parameters.offset = 0;
      this.parameters.order_id = this.orderId;
      $.getJSON(url, this.parameters, this.onLoad, this.onLoadError);
    },

    onLoad: function(res) {
      this.catalog.products = [];
      this.onLoadMore(res);
    },

    loadMoreProducts: function(url) {
      if(this.loading || !this.catalog.hasMore) return;
      this.loading = true;
      this.parameters.offset = this.catalog.products.length;
      this.parameters.order_id = this.orderId;
      $.getJSON(url, this.parameters, this.onLoadMore, this.onLoadError);
    },

    onLoadMore: function(res) {
      this.catalog.featuredPromotion = res.featured_promotion;
      if (this.catalog.featuredPromotion.product)
        this.catalog.featuredPromotion.product = Object.assign({}, res.featured_promotion.product, res.sellers[res.featured_promotion.product.seller_id]);
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

    updateProduct: function(productId, quantity, netPrice, salePrice, feeType, totalPrice, lotId, ctId) {
      // I can pull out a non-general product from our catalog, edit it, and automatically alter the catalog
      // itself because JS always passes objects by reference.
      //
      // Thanks, Javascript!
      var product = _.find(_.flatten(_.pluck(this.catalog.products, 'available')), {id: productId});
      if(!product) return;
      product.cart_item_quantity = quantity;
      product.cart_item_net_price = netPrice;
      product.cart_item_sale_price = salePrice;
      product.cart_item_lot_id = lotId;
      product.cart_item_ct_id = ctId;
      product.total_price = totalPrice;
      product.cart_item_fee_type = feeType;
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
