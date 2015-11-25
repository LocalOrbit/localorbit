(function() {

  var ProductRowMixin = {
    propTypes: {
      hideImages: React.PropTypes.bool.isRequired,
      product: React.PropTypes.shape({
        id: React.PropTypes.number.isRequired,
        name: React.PropTypes.string.isRequired,
        second_level_category_name: React.PropTypes.string,
        short_description: React.PropTypes.string,
        long_description: React.PropTypes.string,
        image_url: React.PropTypes.string,

        available: React.PropTypes.arrayOf(React.PropTypes.shape({
          id: React.PropTypes.number.isRequired,
          unit: React.PropTypes.string.isRequired,
          prices: React.PropTypes.array,
          total_price: React.PropTypes.string,
          max_available: React.PropTypes.number,
          min_available: React.PropTypes.number,
          price_for_quantity: React.PropTypes.string,
          cart_item_persisted: React.PropTypes.bool,
          cart_item_quantity: React.PropTypes.number,
          cart_item: React.PropTypes.object
        })).isRequired,

        who_story: React.PropTypes.string,
        how_story: React.PropTypes.string,
        location_label: React.PropTypes.string,
        location_map_url: React.PropTypes.string
      })
    }
  };

  window.lo = window.lo || {};
  window.lo.ProductRowMixin = ProductRowMixin;
}).call(this);
