(function() {

  var MobileProductUnitPrices = React.createClass({
    propTypes: {
      product: React.PropTypes.shape({
        id: React.PropTypes.number.isRequired,
        unit: React.PropTypes.string.isRequired,
        unit_description: React.PropTypes.string,
        prices: React.PropTypes.array.isRequired,
        total_price: React.PropTypes.string.isRequired,
        max_available: React.PropTypes.number.isRequired,
        cart_item_quantity: React.PropTypes.number.isRequired,
        cart_item: React.PropTypes.object.isRequired
      }).isRequired,
      quantity: React.PropTypes.number.isRequired
    },

    priceCellClasses: function(price) {
      var classes = "";
      var product = this.props.product;
      if(product.cart_item_quantity > 0 && product.price_for_quantity === price.sale_price) {
        classes += "selected";
      }
      return classes;
    },

    pricingCells: function(prices, showCaret) {
      var priceCells = [];
      for(var i = 0; i < 3; i++) {
        if(prices[i]) {
          var classes = this.priceCellClasses(prices[i]);
          priceCells.unshift(
            <td className={classes}>
              {prices[i].sale_price}<br/>
              <span className="price-label">Min. {prices[i].min_quantity}</span>
            </td>
          );
        }
        else {
          priceCells.unshift(<td><span style={{visibility: "hidden"}}>_____</span></td>);
        }
      }
      return ({priceCells});
    },

    unitCell: function(totalRows) {
      var product = this.props.product;
      var max_available = product.max_available ? +product.max_available : 0;
      var max_available_description = max_available < 500000 ? max_available + " Avail." : "";
      return (
        <th rowSpan={totalRows}>
          {product.unit_description}
          <span style={{display: "block", fontSize: "12px", color: "#999"}}>{max_available_description}</span>
        </th>
      );
    },

    render: function() {
      var self = this;
      var groupedPrices = _.toArray(_.groupBy(self.props.product.prices, function(element, index){
        return Math.floor(index/3);
      }));
      var pricingRows = _.map(groupedPrices, function(priceGroup, index) {
        var priceCells = self.pricingCells(priceGroup);
        var unitCell = (index === 0) ? self.unitCell(groupedPrices.length) : null;
        return (
          <tr>
            {unitCell}
            {priceCells}
          </tr>
        );
      });
      return (<div>{pricingRows}</div>);
    }
  });

  window.lo = window.lo || {};
  window.lo.MobileProductUnitPrices = MobileProductUnitPrices;
}).call(this);
