var ProductTable = React.createClass({
  render: function() {
    var rows = [];
    console.log
    this.props.products.forEach(function(product) {
      rows.push ( <ProductRow key={product.id} product={product} /> )
    });
    return (
      <table id="product-search-table" className="product-table product-table--user cart_items" data-cart-url={this.props.cartUrl}>
        <thead></thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
});
