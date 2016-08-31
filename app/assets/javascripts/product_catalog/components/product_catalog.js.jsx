//= require underscore
//= require moment.min
//= require product_catalog/product_store

(function() {
  window.lo = window.lo || {};

  var ProductCatalog = React.createClass({
    propTypes: {
      cartUrl: React.PropTypes.string,
      baseUrl: React.PropTypes.string.isRequired,
      deliveryDate: React.PropTypes.string.isRequired,
      selectedType: React.PropTypes.string,
      orderCutoff: React.PropTypes.string.isRequired,
      buyerInfo: React.PropTypes.string.isRequired,
      useTemplates: React.PropTypes.bool.isRequired,
      supplierId: React.PropTypes.number,
      orderId: React.PropTypes.number,
      orderMinimum: React.PropTypes.number
    },

      componentWillMount: function() {
          window.lo.ProductStore.orderId = this.props.orderId;
      },
      
      render: function() {

        var orderTemplates;
        var productFilter;
        var productTable;

        if(this.props.useTemplates && !this.props.orderId)
            orderTemplates = (<lo.TemplatePicker baseUrl={this.props.baseUrl} cartUrl={this.props.cartUrl} />);
        else
            orderTemplates = ('');

        if (this.props.supplierId > 0)
            window.lo.ProductActions.newFilters(null, this.props.supplierId);

        if (this.props.orderId > 0)
            productFilter = ('');
        else
            productFilter = (<lo.ProductFilter
            deliveryDate={this.props.deliveryDate}
            selectedType={this.props.selectedType}
            orderCutoff={this.props.orderCutoff}
            buyerInfo={this.props.buyerInfo}
            useTemplates={this.props.useTemplates}
            supplierOnly={this.props.supplierId > 0}
            orderId={this.props.orderId}
            orderMinimum={this.props.orderMinimum}
            />);

        productTable = (<lo.ProductTable
            limit={30}
            filter={null}
            cartUrl={this.props.cartUrl}
            url={this.props.baseUrl + '/products'}
            supplierOnly={this.props.supplierId > 0}
            orderId={this.props.orderId}
        />);
        
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
