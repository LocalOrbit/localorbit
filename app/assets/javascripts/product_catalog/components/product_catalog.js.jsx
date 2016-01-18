//= require underscore
//= require moment.min
//= require product_catalog/product_store

(function() {
  window.lo = window.lo || {};

  var ProductCatalog = React.createClass({
    propTypes: {
      cartUrl: React.PropTypes.string.isRequired,
      baseUrl: React.PropTypes.string.isRequired,
      deliveryDate: React.PropTypes.string.isRequired,
      selectedType: React.PropTypes.string.isRequired,
      orderCutoff: React.PropTypes.string.isRequired,
      buyerInfo: React.PropTypes.string.isRequired,
      useTemplates: React.PropTypes.bool.isRequired,
      supplierId: React.PropTypes.number
    },

      render: function() {

        var orderTemplates;
        var productFilter;
        var productTable;

        if(this.props.useTemplates)
            orderTemplates = (<lo.TemplatePicker baseUrl={this.props.baseUrl} cartUrl={this.props.cartUrl} />);
        else
            orderTemplates = ('');

        if (this.props.supplierId > 0) {
            window.lo.ProductActions.newFilters(null, this.props.supplierId);
            productFilter = ('');
            productTable = (<lo.ProductTable
                limit={30}
                filter={null}
                cartUrl={this.props.cartUrl}
                url={this.props.baseUrl + '/products'}
                supplierOnly={true}
            />);
        }
        else {
            productFilter = (<lo.ProductFilter
                deliveryDate={this.props.deliveryDate}
                selectedType={this.props.selectedType}
                orderCutoff={this.props.orderCutoff}
                buyerInfo={this.props.buyerInfo}
                useTemplates={this.props.useTemplates}
            />);
            productTable = (<lo.ProductTable
                limit={30}
                filter={null}
                cartUrl={this.props.cartUrl}
                url={this.props.baseUrl + '/products'}
                supplierOnly={false}
            />);
        }
        return (
        <div>
          {orderTemplates}
          {productFilter}
          {productTable}
        </div>
      );
    }
  });

  window.lo.ProductCatalog = ProductCatalog;
}).call(this);
